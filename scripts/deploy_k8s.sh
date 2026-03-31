#!/bin/bash

# AI Life Ops Assistant - K8s Deployment Script
# Extreme automation for the Masterpiece

echo "🚀 Starting Kubernetes Deployment for AI Life Ops Masterpiece..."

# 1. Create Secrets (if not exists)
kubectl create secret generic ai-life-ops-secrets \
  --from-literal=OPENAI_API_KEY=$OPENAI_API_KEY \
  --dry-run=client -o yaml | kubectl apply -f -

# 2. Apply Manifests
echo "📦 Applying Deployment & Service..."
kubectl apply -f k8s/deployment.yaml

echo "📈 Applying Horizontal Pod Autoscaler..."
kubectl apply -f k8s/hpa.yaml

# 3. Rollout Status
echo "⏳ Waiting for rollout..."
kubectl rollout status deployment/ai-life-ops-backend

echo "✅ Masterpiece Deployed Successfully to K8s Cluster!"
