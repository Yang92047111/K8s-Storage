#!/bin/bash
set -e

echo "🧪 Starting storage test..."

# Get pod name
POD=$(kubectl get pod -l app=go-app -o jsonpath="{.items[0].metadata.name}")
echo "📋 Testing with pod: $POD"

# Wait for pod to be ready
echo "⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=Ready pod/$POD --timeout=60s

# Port forward to access the service
echo "🔗 Setting up port forwarding..."
kubectl port-forward pod/$POD 8080:8080 &
PORT_FORWARD_PID=$!

# Wait a moment for port forwarding to establish
sleep 3

# Test the write endpoint
echo "📝 Sending write request..."
TEST_MSG="kind-storage-test-$(date +%s)"
curl -s "http://localhost:8080/write?msg=$TEST_MSG" || {
    echo "❌ Failed to send write request"
    kill $PORT_FORWARD_PID 2>/dev/null || true
    exit 1
}

echo ""
echo "🔍 Verifying data was written..."
sleep 1

# Check if data was written correctly
WRITTEN_DATA=$(kubectl exec $POD -- cat /data/output.txt 2>/dev/null || echo "")
if [[ "$WRITTEN_DATA" == "$TEST_MSG" ]]; then
    echo "✅ Data written successfully: $WRITTEN_DATA"
else
    echo "❌ Data verification failed. Expected: $TEST_MSG, Got: $WRITTEN_DATA"
    kill $PORT_FORWARD_PID 2>/dev/null || true
    exit 1
fi

# Test persistence by restarting pod
echo "🔄 Testing persistence by restarting pod..."
kubectl delete pod $POD
kubectl wait --for=condition=Ready pod -l app=go-app --timeout=60s

# Get new pod name
NEW_POD=$(kubectl get pod -l app=go-app -o jsonpath="{.items[0].metadata.name}")
echo "📋 New pod: $NEW_POD"

# Verify data persisted
PERSISTED_DATA=$(kubectl exec $NEW_POD -- cat /data/output.txt 2>/dev/null || echo "")
if [[ "$PERSISTED_DATA" == "$TEST_MSG" ]]; then
    echo "✅ Data persistence verified: $PERSISTED_DATA"
else
    echo "❌ Data persistence failed. Expected: $TEST_MSG, Got: $PERSISTED_DATA"
    kill $PORT_FORWARD_PID 2>/dev/null || true
    exit 1
fi

# Cleanup
kill $PORT_FORWARD_PID 2>/dev/null || true

echo "🎉 All tests passed! Storage experiment completed successfully."