#!/bin/bash

# Script to create Docker registry secret for Kubernetes
# Usage: ./scripts/create-docker-secret.sh <dockerhub-username> <dockerhub-token>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <dockerhub-username> <dockerhub-token>"
    echo "Example: $0 docker4zerocool your-dockerhub-token"
    exit 1
fi

DOCKERHUB_USERNAME=$1
DOCKERHUB_TOKEN=$2
NAMESPACE="dev-template"
SECRET_NAME="docker-registry-secret"

echo "Creating Docker registry secret for namespace: $NAMESPACE"

# Create the secret
kubectl create secret docker-registry $SECRET_NAME \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=$DOCKERHUB_USERNAME \
    --docker-password=$DOCKERHUB_TOKEN \
    --docker-email=$DOCKERHUB_USERNAME@example.com \
    --namespace=$NAMESPACE \
    --dry-run=client -o yaml > k8s/base/docker-secret.yaml

echo "Docker registry secret created in k8s/base/docker-secret.yaml"
echo "You can now apply it with: kubectl apply -f k8s/base/docker-secret.yaml"
echo ""
echo "Or create it directly with:"
echo "kubectl create secret docker-registry $SECRET_NAME \\"
echo "    --docker-server=https://index.docker.io/v1/ \\"
echo "    --docker-username=$DOCKERHUB_USERNAME \\"
echo "    --docker-password=$DOCKERHUB_TOKEN \\"
echo "    --docker-email=$DOCKERHUB_USERNAME@example.com \\"
echo "    --namespace=$NAMESPACE"
