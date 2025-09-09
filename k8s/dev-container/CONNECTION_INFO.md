# Dev Container Connection Information

## 🎉 Deployment Successful!

Your dev container has been successfully deployed to the Kubernetes cluster in the `dev-environment` namespace.

## 📋 Connection Details

### SSH Access
- **Host**: `192.168.0.21` (gpu-server node IP)
- **Port**: `30223` (NodePort service)
- **Username**: `developer`
- **Password**: `devpass123`

### SSH Command
```bash
ssh -p 30223 developer@192.168.0.21
```

**Note**: The SSH connection goes through the Kubernetes NodePort service, which forwards traffic from port 30223 on the node to port 22 in the container.

### Alternative Connection Methods

#### Via kubectl exec (for debugging)
```bash
kubectl exec -it -n dev-environment deployment/dev-container -- /bin/bash
```

#### Port Forward (for local development)
```bash
kubectl port-forward -n dev-environment svc/dev-container 2222:22
# Then connect via: ssh -p 2222 developer@localhost
```

## 🛠️ Development Environment

The container includes:

### Languages & Runtimes
- **Python 3.10+** with Poetry package manager
- **Node.js 18+** with npm
- **Git** for version control

### Development Tools
- **Editors**: vim, nano
- **System tools**: htop, tree, curl, wget, jq
- **Container tools**: Docker CLI, kubectl, Helm
- **Database clients**: PostgreSQL client, Redis CLI

### Python Packages (Pre-installed)
- FastAPI, uvicorn, SQLAlchemy, Alembic
- psycopg2-binary, redis, pydantic
- pytest, pytest-asyncio
- minio, openai, boto3

### Node.js Packages (Pre-installed)
- TypeScript, ts-node, nodemon, pm2
- Express, cors, helmet, morgan
- Jest, supertest

### Workspace
- **Working directory**: `/workspace` (persistent storage)
- **User home**: `/home/developer`
- **Sudo access**: Available for system operations

## 🔧 Environment Variables

The container has access to your existing services:
- **PostgreSQL**: Connected via `pg-app` secret
- **Redis**: Connected via `redis-app` secret  
- **MinIO**: Connected via `minio-app` secret

## 👥 Team Management

### Adding Team Members
```bash
# Generate SSH key for team member
./team-setup.sh generate john

# Add team member with their public key
./team-setup.sh add john "ssh-rsa AAAAB3NzaC1yc2E... john@laptop"

# List current team members
./team-setup.sh list
```

### SSH Key Authentication
Team members can use either:
1. **Password authentication**: `developer` / `devpass123`
2. **SSH key authentication**: Add their public key using the team setup script

## 📊 Monitoring

### Check Container Status
```bash
kubectl get pods -n dev-environment -l app.kubernetes.io/name=dev-container
```

### View Logs
```bash
kubectl logs -n dev-environment -l app.kubernetes.io/name=dev-container
```

### Resource Usage
```bash
kubectl top pods -n dev-environment -l app.kubernetes.io/name=dev-container
```

## 🔄 Updates & Maintenance

### Updating the Container
1. Modify the Dockerfile in `/root/dev-pynode/docker/dev-container/`
2. Run: `./build-and-deploy.sh`
3. The deployment will automatically update

### Scaling
```bash
kubectl scale deployment dev-container -n dev-environment --replicas=3
```

## 🐛 Troubleshooting

### Common Issues

1. **SSH connection refused**:
   - Check if the pod is running: `kubectl get pods -n dev-environment`
   - Verify the service: `kubectl get svc dev-container -n dev-environment`

2. **Permission issues**:
   - Container runs as root with developer user available
   - Use `sudo` for system operations

3. **Storage issues**:
   - Workspace is mounted at `/workspace` with 10GB persistent storage
   - Uses local-path storage class

### Getting Help
- Check pod events: `kubectl get events -n dev-environment`
- View service endpoints: `kubectl get endpoints dev-container -n dev-environment`

## 📁 File Locations

- **Kubernetes manifests**: `/root/dev-pynode/k8s/dev-container/`
- **Dockerfile**: `/root/dev-pynode/docker/dev-container/Dockerfile`
- **Deployment script**: `/root/dev-pynode/k8s/dev-container/build-and-deploy.sh`
- **Team management**: `/root/dev-pynode/k8s/dev-container/team-setup.sh`

## 🎯 Next Steps

1. **Test the connection**: `ssh -p 30223 developer@192.168.0.21`
2. **Add team members**: Use the team setup script
3. **Start developing**: The environment is ready for Python, Node.js, and container development
4. **Access services**: PostgreSQL, Redis, and MinIO are pre-configured

Your dev container is now ready for your team to use! 🚀
