#!/bin/bash

# Build and Deploy Dev Container Script
# This script builds the Docker image and deploys it to Kubernetes

set -e

# Configuration
IMAGE_NAME="dev-container"
IMAGE_TAG="latest"
NAMESPACE="dev-environment"
K8S_MANIFESTS_DIR="/root/dev-pynode/k8s/dev-container"

echo "🚀 Starting Dev Container Build and Deploy Process..."

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."
if ! command_exists docker; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if ! command_exists kubectl; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if kubectl can connect to cluster
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "❌ Cannot connect to Kubernetes cluster"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Build Docker image
echo "🔨 Building Docker image..."
cd /root/dev-pynode/docker/dev-container

# Build the image
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

echo "✅ Docker image built successfully"

# Load image into kind cluster (if using kind)
if kubectl config current-context | grep -q "kind"; then
    echo "📦 Loading image into kind cluster..."
    kind load docker-image ${IMAGE_NAME}:${IMAGE_TAG}
    echo "✅ Image loaded into kind cluster"
fi

# Apply Kubernetes manifests
echo "🚀 Deploying to Kubernetes..."
cd ${K8S_MANIFESTS_DIR}

# Apply the manifests
kubectl apply -k .

echo "✅ Kubernetes manifests applied"

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/dev-container -n ${NAMESPACE}

# Get service information
echo "📊 Getting service information..."
kubectl get svc dev-container -n ${NAMESPACE}

# Get pod information
echo "📊 Getting pod information..."
kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=dev-container

echo "🎉 Dev Container deployment completed successfully!"
echo ""
echo "📝 Connection Information:"
echo "   SSH Host: <node-ip>"
echo "   SSH Port: 30222"
echo "   Username: developer"
echo "   Password: devpass123"
echo ""
echo "🔍 To get the node IP, run:"
echo "   kubectl get nodes -o wide"
echo ""
echo "🔍 To check pod status, run:"
echo "   kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/name=dev-container"
echo ""
echo "🔍 To view logs, run:"
echo "   kubectl logs -n ${NAMESPACE} -l app.kubernetes.io/name=dev-container"


