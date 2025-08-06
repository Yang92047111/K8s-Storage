#!/bin/bash
set -e

echo "🔧 Deploying Kubernetes manifests..."

echo "📦 Applying StorageClass..."
kubectl apply -f manifests/storageclass.yaml

echo "💾 Applying PersistentVolume..."
kubectl apply -f manifests/pv.yaml

echo "📋 Applying PersistentVolumeClaim..."
kubectl apply -f manifests/pvc.yaml

echo "🐳 Building Docker image..."
docker build -t go-app:latest .

echo "📤 Loading image into Kind cluster..."
kind load docker-image go-app:latest --name storage-demo

echo "🚀 Deploying application..."
kubectl apply -f manifests/deployment.yaml

echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/go-app

echo "✅ Deployment completed successfully!"
echo "📋 Pod status:"
kubectl get pods -l app=go-app
echo "📋 PVC status:"
kubectl get pvc