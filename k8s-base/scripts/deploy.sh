#!/bin/bash

# =============================================================================
# K8s-Base Deployment Script
# =============================================================================

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANIFESTS_DIR="$(dirname "$SCRIPT_DIR")/manifests"

log_info "Deploying k8s-base setup..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes
if ! kubectl cluster-info &> /dev/null; then
    log_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

# Deploy the manifests
log_info "Applying Kubernetes manifests..."
kubectl apply -k "$MANIFESTS_DIR"

# Wait for deployment to be ready
log_info "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/dev-template -n dev-template

# Get the NodePort
log_info "Getting SSH service information..."
NODEPORT=$(kubectl get svc dev-template-ssh -n dev-template -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="ExternalIP")].address}')
if [ -z "$NODE_IP" ]; then
    NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
fi

log_success "Deployment completed successfully!"
echo
echo "=========================================="
echo "  SSH Access Information"
echo "=========================================="
echo "Node IP: $NODE_IP"
echo "SSH Port: $NODEPORT"
echo "Username: developer"
echo "Password: dev123"
echo
echo "SSH Command:"
echo "ssh developer@$NODE_IP -p $NODEPORT"
echo
echo "=========================================="
echo "  Useful Commands"
echo "=========================================="
echo "Check pod status:"
echo "kubectl get pods -n dev-template"
echo
echo "Check service:"
echo "kubectl get svc -n dev-template"
echo
echo "View pod logs:"
echo "kubectl logs -f deployment/dev-template -n dev-template"
echo
echo "Delete deployment:"
echo "kubectl delete -k $MANIFESTS_DIR"
echo
