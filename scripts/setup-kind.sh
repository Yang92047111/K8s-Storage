#!/bin/bash
echo "🚀 Creating Kind cluster for storage demo..."
kind create cluster --name storage-demo

echo "✅ Kind cluster 'storage-demo' created successfully!"
echo "📋 Cluster info:"
kubectl cluster-info --context kind-storage-demo