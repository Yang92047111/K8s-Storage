#!/bin/bash

echo "🔍 Kubernetes Storage Experiment Status"
echo "======================================="

# Check if Kind cluster exists
if kind get clusters | grep -q "storage-demo"; then
    echo "✅ Kind cluster 'storage-demo' is running"
    
    # Check cluster connectivity
    if kubectl cluster-info --context kind-storage-demo >/dev/null 2>&1; then
        echo "✅ Cluster connectivity OK"
        
        # Check storage resources
        echo ""
        echo "📦 Storage Resources:"
        kubectl get storageclass,pv,pvc --no-headers 2>/dev/null | while read line; do
            echo "  ✅ $line"
        done
        
        # Check application
        echo ""
        echo "🚀 Application Status:"
        POD_STATUS=$(kubectl get pods -l app=go-app -o jsonpath='{.items[0].status.phase}' 2>/dev/null)
        if [[ "$POD_STATUS" == "Running" ]]; then
            POD_NAME=$(kubectl get pods -l app=go-app -o jsonpath='{.items[0].metadata.name}')
            echo "  ✅ Pod $POD_NAME is running"
            
            # Check if data exists
            if kubectl exec $POD_NAME -- test -f /data/output.txt 2>/dev/null; then
                DATA=$(kubectl exec $POD_NAME -- cat /data/output.txt 2>/dev/null)
                echo "  ✅ Persistent data exists: $DATA"
            else
                echo "  ⚠️  No persistent data found"
            fi
        else
            echo "  ❌ Application pod not running (status: $POD_STATUS)"
        fi
        
    else
        echo "❌ Cannot connect to cluster"
    fi
else
    echo "❌ Kind cluster 'storage-demo' not found"
    echo "   Run 'make setup' to create the cluster"
fi

echo ""
echo "💡 Available commands:"
echo "   make help    - Show all available commands"
echo "   make status  - Show this status (if added to Makefile)"