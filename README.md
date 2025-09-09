<<<<<<< HEAD
# Dev-PyNode

A comprehensive AI-powered development platform built with Node.js, Python, and modern containerization technologies.

## 🚀 Features

- **Hybrid Backend**: Node.js and Python services working together
- **AI Integration**: OpenAI API and local AI models (Ollama)
- **Modern Stack**: FastAPI, Express.js, PostgreSQL, Redis, MinIO
- **Containerized**: Full Docker and Kubernetes support
- **CI/CD Ready**: GitHub Actions pipeline with automated testing and deployment
- **Monitoring**: Prometheus, Grafana, and comprehensive logging
- **Security**: JWT authentication, rate limiting, and security scanning

## 📋 Prerequisites

- Docker and Docker Compose
- Node.js 18+
- Python 3.11+
- Kubernetes cluster (for production deployment)
- Git

## 🛠️ Quick Start

### Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Bionic-AI-Solutions/dev-pynode.git
   cd dev-pynode
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start development environment**
   ```bash
   docker-compose up -d
   ```

4. **Access the application**
   - Frontend: http://localhost:3001
   - Backend API: http://localhost:3000
   - API Documentation: http://localhost:3000/docs
   - pgAdmin: http://localhost:5050
   - Redis Commander: http://localhost:8081
   - MinIO Console: http://localhost:9001
   - Grafana: http://localhost:3003 (admin/admin123)

### Production Deployment

1. **Deploy to Kubernetes**
   ```bash
   kubectl apply -k k8s/overlays/production
   ```

2. **Check deployment status**
   ```bash
   kubectl get pods -n dev-pynode
   kubectl get services -n dev-pynode
   ```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend       │    │   AI Services   │
│   (React)       │◄──►│   (Node.js)     │◄──►│   (Ollama)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                                │
                       ┌─────────────────┐
                       │   Data Layer    │
                       │ PostgreSQL      │
                       │ Redis           │
                       │ MinIO           │
                       └─────────────────┘
```

## 📁 Project Structure

```
dev-pynode/
├── .github/workflows/          # CI/CD pipelines
├── backend/                    # Backend services
│   ├── nodejs/                # Node.js API
│   └── python/                # Python services
├── frontend/                   # React frontend
├── k8s/                       # Kubernetes manifests
│   ├── base/                  # Base configurations
│   └── overlays/              # Environment-specific configs
├── docker/                    # Docker configurations
├── scripts/                   # Utility scripts
├── tests/                     # Test suites
│   ├── unit/                  # Unit tests
│   └── integratione2e/        # Integration tests
└── docs/                      # Documentation
```

## 🔧 Configuration

### Environment Variables

Key environment variables (see `.env.example` for complete list):

- `NODE_ENV`: Environment (development/production)
- `DB_HOST`: PostgreSQL host
- `REDIS_HOST`: Redis host
- `MINIO_ENDPOINT`: MinIO endpoint
- `OPENAI_API_KEY`: OpenAI API key
- `JWT_SECRET`: JWT signing secret

### AI Models

The application supports both OpenAI API and local AI models:

- **OpenAI**: GPT-4, GPT-3.5-turbo
- **Local AI**: Ollama with Llama2, CodeLlama, and other models

## 🧪 Testing

### Run Tests

```bash
# Unit tests
npm run test:unit
pytest tests/unit/

# Integration tests
npm run test:integration
pytest tests/integratione2e/

# All tests
npm test
```

### Test Coverage

```bash
# Generate coverage report
npm run test:coverage
pytest --cov=backend tests/
```

## 🚀 Deployment

### Docker

```bash
# Build image
docker build -t dev-pynode .

# Run container
docker run -p 3000:3000 dev-pynode
```

### Kubernetes

```bash
# Development
kubectl apply -k k8s/overlays/development

# Production
kubectl apply -k k8s/overlays/production
```

### CI/CD

The project includes a comprehensive GitHub Actions pipeline:

- Code quality checks (ESLint, Prettier, TypeScript)
- Security scanning (Bandit, npm audit, Trivy)
- Automated testing (unit, integration, e2e)
- Docker image building and pushing
- Kubernetes deployment
- Performance testing with Lighthouse

## 📊 Monitoring

### Metrics

- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **Application**: Custom metrics via `/metrics` endpoint

### Logging

- **Structured logging**: JSON format
- **Log levels**: DEBUG, INFO, WARN, ERROR
- **Log rotation**: Automatic with size limits

### Health Checks

- **Liveness**: `/health` endpoint
- **Readiness**: `/ready` endpoint
- **Kubernetes**: Automatic health checks

## 🔒 Security

### Authentication

- JWT-based authentication
- Refresh token support
- Role-based access control

### Security Features

- Rate limiting
- CORS configuration
- Input validation
- SQL injection prevention
- XSS protection
- CSRF protection

### Security Scanning

- **Dependencies**: npm audit, pip-audit
- **Code**: Bandit, ESLint security rules
- **Images**: Trivy vulnerability scanning
- **Infrastructure**: Kubernetes security policies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the coding standards defined in `.eslintrc.js` and `pyproject.toml`
- Write tests for new features
- Update documentation as needed
- Ensure all CI checks pass

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [docs/](docs/)
- **Issues**: [GitHub Issues](https://github.com/Bionic-AI-Solutions/dev-pynode/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Bionic-AI-Solutions/dev-pynode/discussions)

## 🏢 About Bionic-AI-Solutions

This project is part of the Bionic-AI-Solutions ecosystem, providing AI-powered development tools and platforms.

---

**Built with ❤️ by the Bionic-AI-Solutions team**

=======
# dev-template
Dev-PyNode: AI-powered development platform with Node.js and Python backend, Docker containerization, and Kubernetes deployment
>>>>>>> b0b8620301cd9841f3b0f53aa393bb07d26eed11
