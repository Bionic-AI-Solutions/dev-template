# Dev Container for Remote Development

This directory contains Kubernetes manifests and scripts to deploy a remote development container that your team can access via SSH.

## 🚀 Quick Start

### Prerequisites
- Docker installed and running
- kubectl configured to access your Kubernetes cluster
- Access to the `dev-environment` namespace

### Deploy the Dev Container

1. **Build and deploy everything:**
   ```bash
   cd /root/dev-pynode/k8s/dev-container
   ./build-and-deploy.sh
   ```

2. **Get connection information:**
   ```bash
   # Get node IP
   kubectl get nodes -o wide
   
   # Get service details
   kubectl get svc dev-container -n dev-environment
   ```

3. **Connect via SSH:**
   ```bash
   ssh -p 30222 developer@<node-ip>
   # Password: devpass123
   ```

## 📁 Directory Structure

```
k8s/dev-container/
├── README.md                    # This file
├── build-and-deploy.sh         # Main deployment script
├── team-setup.sh              # Team member management
├── namespace.yaml             # Namespace definition
├── configmap.yaml             # Configuration
├── secret.yaml                # Secrets (passwords, etc.)
├── ssh-keys-secret.yaml       # SSH public keys
├── pvc.yaml                   # Persistent volume claim
├── deployment.yaml            # Main deployment
├── service.yaml               # Service definition
├── ingress.yaml               # Ingress configuration
└── kustomization.yaml         # Kustomize configuration
```

## 🔧 Configuration

### Environment Variables

The dev container is configured with the following environment variables:

- **Development**: `NODE_ENV=development`, `DEBUG=true`
- **SSH**: Port 22, user `developer`
- **Workspace**: `/workspace` (persistent storage)
- **Database**: Connected to existing PostgreSQL, Redis, and MinIO services

### Resource Limits

- **CPU**: 1-2 cores
- **Memory**: 2-4GB
- **Storage**: 10GB persistent volume

## 👥 Team Management

### Adding Team Members

1. **Generate SSH key for team member:**
   ```bash
   ./team-setup.sh generate john
   ```

2. **Add team member with their public key:**
   ```bash
   ./team-setup.sh add john "ssh-rsa AAAAB3NzaC1yc2E... john@laptop"
   ```

3. **List current team members:**
   ```bash
   ./team-setup.sh list
   ```

4. **Remove team member:**
   ```bash
   ./team-setup.sh remove john
   ```

### SSH Key Management

Team members can connect using either:
- **Password authentication**: `developer` / `devpass123`
- **SSH key authentication**: Add their public key using the team setup script

## 🛠️ Development Tools Included

The dev container comes pre-installed with:

### System Tools
- Ubuntu 22.04 base
- Git, curl, wget, vim, nano, htop, tree
- Network tools (ping, telnet, net-tools)

### Development Languages
- **Python 3.10+** with pip and Poetry
- **Node.js 18+** with npm and global packages
- **Build tools**: gcc, make, build-essential

### Database Clients
- PostgreSQL client
- Redis CLI tools

### Container & Orchestration
- Docker CLI
- kubectl
- Helm

### Python Packages
- FastAPI, uvicorn, SQLAlchemy, Alembic
- psycopg2-binary, redis, pydantic
- pytest, pytest-asyncio
- minio, openai, boto3

### Node.js Packages
- TypeScript, ts-node, nodemon
- Express, cors, helmet, morgan
- Jest, supertest

## 🔐 Security

### Container Security
- Runs as non-root user (`developer`)
- Read-only root filesystem (where possible)
- Dropped capabilities
- Security context configured

### SSH Security
- Password authentication enabled
- Public key authentication supported
- X11 forwarding enabled
- Standard SSH port (22)

## 📊 Monitoring & Logs

### Check Container Status
```bash
# Pod status
kubectl get pods -n dev-environment -l app.kubernetes.io/name=dev-container

# Pod logs
kubectl logs -n dev-environment -l app.kubernetes.io/name=dev-container

# Describe pod for detailed info
kubectl describe pod -n dev-environment -l app.kubernetes.io/name=dev-container
```

### Health Checks
- **Liveness probe**: TCP check on port 22
- **Readiness probe**: TCP check on port 22

## 🔄 Updates & Maintenance

### Updating the Container Image
1. Modify the Dockerfile in `/root/dev-pynode/docker/dev-container/`
2. Run the build script: `./build-and-deploy.sh`
3. The deployment will automatically update

### Scaling
To run multiple dev containers:
```bash
kubectl scale deployment dev-container -n dev-environment --replicas=3
```

### Backup
The workspace data is stored in a persistent volume. To backup:
```bash
# Create a backup pod
kubectl run backup-pod --image=busybox --rm -it --restart=Never -n dev-environment -- tar -czf /backup/workspace.tar.gz -C /workspace .
```

## 🐛 Troubleshooting

### Common Issues

1. **Container not starting:**
   ```bash
   kubectl describe pod -n dev-environment -l app.kubernetes.io/name=dev-container
   kubectl logs -n dev-environment -l app.kubernetes.io/name=dev-container
   ```

2. **SSH connection refused:**
   - Check if the pod is running
   - Verify the service is exposing port 30222
   - Check firewall rules

3. **Storage issues:**
   - Verify PVC is bound: `kubectl get pvc -n dev-environment`
   - Check storage class: `kubectl get storageclass`

4. **Permission issues:**
   - Container runs as user 1000
   - Check file permissions in `/workspace`

### Getting Help

- Check pod events: `kubectl get events -n dev-environment`
- View service endpoints: `kubectl get endpoints dev-container -n dev-environment`
- Check ingress status: `kubectl describe ingress dev-container-ingress -n dev-environment`

## 🔗 Integration with Existing Services

The dev container automatically connects to your existing services:

- **PostgreSQL**: Uses secrets from `pg-app`
- **Redis**: Uses secrets from `redis-app`  
- **MinIO**: Uses secrets from `minio-app`

Environment variables are automatically injected from these secrets.

## 📝 Notes

- The container image is built locally and may need to be pushed to a registry for production use
- SSH keys are managed via Kubernetes secrets
- The workspace directory is persistent across container restarts
- All development tools are pre-installed to minimize setup time


