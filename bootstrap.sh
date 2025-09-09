#!/bin/bash

# =============================================================================
# Dev-PyNode Bootstrap Script
# =============================================================================
# This script initializes a new Dev-PyNode project with all necessary
# configurations and dependencies.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME=""
STACK=""
DESCRIPTION=""
GITHUB_ORG="Bionic-AI-Solutions"

# =============================================================================
# Helper Functions
# =============================================================================

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

check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_deps+=("node")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_deps+=("python3")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and try again."
        exit 1
    fi
    
    log_success "All dependencies are installed"
}

validate_input() {
    if [ -z "$PROJECT_NAME" ]; then
        log_error "Project name is required"
        exit 1
    fi
    
    if [ -z "$STACK" ]; then
        log_error "Stack is required"
        exit 1
    fi
    
    if [ -z "$DESCRIPTION" ]; then
        log_error "Description is required"
        exit 1
    fi
    
    # Validate stack
    case "$STACK" in
        fastapi|nodejs|react|fullstack)
            ;;
        *)
            log_error "Invalid stack. Must be one of: fastapi, nodejs, react, fullstack"
            exit 1
            ;;
    esac
    
    # Validate project name (kebab-case)
    if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
        log_error "Project name must be in kebab-case (e.g., my-awesome-project)"
        exit 1
    fi
}

create_repository() {
    log_info "Creating GitHub repository..."
    
    # Check if GitHub CLI is available
    if command -v gh &> /dev/null; then
        gh repo create "$GITHUB_ORG/$PROJECT_NAME" \
            --description "$DESCRIPTION" \
            --public \
            --clone
    else
        log_warning "GitHub CLI not found. Please create the repository manually:"
        log_info "Repository URL: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
        log_info "Description: $DESCRIPTION"
        log_info "Visibility: Public"
    fi
}

setup_project_structure() {
    log_info "Setting up project structure..."
    
    # Create directories
    mkdir -p backend/{nodejs,python}
    mkdir -p frontend
    mkdir -p scripts
    mkdir -p tests/{unit,integratione2e}
    mkdir -p docs/feature
    mkdir -p k8s/{base,overlays/{development,staging,production}}
    mkdir -p docker
    mkdir -p .github/{workflows,ISSUE_TEMPLATE}
    
    log_success "Project structure created"
}

setup_environment() {
    log_info "Setting up environment configuration..."
    
    # Copy and customize .env.example
    if [ -f ".env.example" ]; then
        cp .env.example .env
        sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" .env
        sed -i "s/dev-pynode/$PROJECT_NAME/g" .env
        log_success "Environment configuration created"
    else
        log_warning ".env.example not found, skipping environment setup"
    fi
}

setup_package_files() {
    log_info "Setting up package files..."
    
    # Update package.json
    if [ -f "package.json" ]; then
        sed -i "s/dev-pynode/$PROJECT_NAME/g" package.json
        sed -i "s/AI-powered development platform with Node.js and Python backend/$DESCRIPTION/g" package.json
        log_success "package.json updated"
    fi
    
    # Update requirements.txt
    if [ -f "requirements.txt" ]; then
        log_success "requirements.txt ready"
    fi
}

setup_docker() {
    log_info "Setting up Docker configuration..."
    
    # Update docker-compose.yml
    if [ -f "docker-compose.yml" ]; then
        sed -i "s/dev-pynode/$PROJECT_NAME/g" docker-compose.yml
        sed -i "s/dev-template/$PROJECT_NAME/g" docker-compose.yml
        log_success "Docker configuration updated"
    fi
    
    # Update Dockerfile
    if [ -f "Dockerfile" ]; then
        sed -i "s/dev-pynode/$PROJECT_NAME/g" Dockerfile
        sed -i "s/dev-template/$PROJECT_NAME/g" Dockerfile
        log_success "Dockerfile updated"
    fi
}

setup_kubernetes() {
    log_info "Setting up Kubernetes manifests..."
    
    # Update k8s manifests
    find k8s/ -name "*.yaml" -exec sed -i "s/dev-pynode/$PROJECT_NAME/g" {} \;
    find k8s/ -name "*.yaml" -exec sed -i "s/dev_pynode_db/${PROJECT_NAME//-/_}_db/g" {} \;
    find k8s/ -name "*.yaml" -exec sed -i "s/dev_template/${PROJECT_NAME//-/_}_db/g" {} \;
    
    log_success "Kubernetes manifests updated"
}

setup_github_actions() {
    log_info "Setting up GitHub Actions..."
    
    # Update CI/CD pipeline
    if [ -f ".github/workflows/ci-cd.yml" ]; then
        sed -i "s/dev-pynode/$PROJECT_NAME/g" .github/workflows/ci-cd.yml
        sed -i "s/bionic-ai-solutions\/dev-pynode/$GITHUB_ORG\/$PROJECT_NAME/g" .github/workflows/ci-cd.yml
        log_success "GitHub Actions pipeline updated"
    fi
}

setup_documentation() {
    log_info "Setting up documentation..."
    
    # Update README.md
    if [ -f "README.md" ]; then
        sed -i "s/Dev-PyNode/$PROJECT_NAME/g" README.md
        sed -i "s/dev-pynode/$PROJECT_NAME/g" README.md
        sed -i "s/AI-powered development platform with Node.js and Python backend/$DESCRIPTION/g" README.md
        log_success "Documentation updated"
    fi
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    # Install Node.js dependencies
    if [ -f "package.json" ]; then
        npm install
        log_success "Node.js dependencies installed"
    fi
    
    # Install Python dependencies
    if [ -f "requirements.txt" ]; then
        pip3 install -r requirements.txt
        log_success "Python dependencies installed"
    fi
    
    # Install development dependencies
    if [ -f "requirements-dev.txt" ]; then
        pip3 install -r requirements-dev.txt
        log_success "Python development dependencies installed"
    fi
}

setup_git() {
    log_info "Setting up Git repository..."
    
    # Initialize git if not already initialized
    if [ ! -d ".git" ]; then
        git init
        log_success "Git repository initialized"
    fi
    
    # Add all files
    git add .
    
    # Create initial commit
    git commit -m "Initial commit: Bootstrap $PROJECT_NAME project

- Set up project structure
- Configure Docker and Kubernetes
- Set up CI/CD pipeline
- Add documentation
- Configure code quality tools

Stack: $STACK
Description: $DESCRIPTION"
    
    log_success "Initial commit created"
}

setup_hooks() {
    log_info "Setting up Git hooks..."
    
    # Install husky if package.json exists
    if [ -f "package.json" ] && grep -q "husky" package.json; then
        npm run prepare
        log_success "Git hooks installed"
    fi
}

create_initial_files() {
    log_info "Creating initial application files..."
    
    # Create basic application structure based on stack
    case "$STACK" in
        fastapi)
            create_fastapi_structure
            ;;
        nodejs)
            create_nodejs_structure
            ;;
        react)
            create_react_structure
            ;;
        fullstack)
            create_fullstack_structure
            ;;
    esac
}

create_fastapi_structure() {
    log_info "Creating FastAPI structure..."
    
    mkdir -p backend/python/{app,models,routes,services,utils}
    
    cat > backend/python/app/main.py << 'EOF'
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

app = FastAPI(
    title="Dev-PyNode API",
    description="AI-powered development platform",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "Hello from FastAPI!"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
    
    log_success "FastAPI structure created"
}

create_nodejs_structure() {
    log_info "Creating Node.js structure..."
    
    mkdir -p src/{controllers,middleware,models,routes,services,utils,config}
    
    cat > src/index.ts << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.APP_PORT || 3000;

// Middleware
app.use(helmet());
app.use(compression());
app.use(morgan('combined'));
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.get('/', (req, res) => {
  res.json({ message: 'Hello from Node.js!' });
});

app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
EOF
    
    log_success "Node.js structure created"
}

create_react_structure() {
    log_info "Creating React structure..."
    
    mkdir -p frontend/{src,public}
    mkdir -p frontend/src/{components,pages,hooks,utils,services}
    
    cat > frontend/src/App.tsx << 'EOF'
import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Welcome to Dev-PyNode</h1>
        <p>AI-powered development platform</p>
      </header>
    </div>
  );
}

export default App;
EOF
    
    log_success "React structure created"
}

create_fullstack_structure() {
    log_info "Creating full-stack structure..."
    
    create_nodejs_structure
    create_react_structure
    
    log_success "Full-stack structure created"
}

run_tests() {
    log_info "Running initial tests..."
    
    # Run tests if they exist
    if [ -f "package.json" ] && grep -q "test" package.json; then
        npm test || log_warning "Tests failed, but continuing..."
    fi
    
    log_success "Initial tests completed"
}

show_completion_message() {
    log_success "Project bootstrap completed successfully!"
    echo
    echo "Next steps:"
    echo "1. Review and customize the configuration files"
    echo "2. Update the .env file with your specific settings"
    echo "3. Start development: docker-compose up -d"
    echo "4. Access the application at http://localhost:3000"
    echo
    echo "Useful commands:"
    echo "- Start development: docker-compose up -d"
    echo "- Run tests: npm test"
    echo "- Deploy to K8s: kubectl apply -k k8s/overlays/development"
    echo
    echo "Documentation: docs/README.md"
    echo "GitHub repository: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
}

# =============================================================================
# Main Script
# =============================================================================

main() {
    echo "=========================================="
    echo "  Dev-PyNode Bootstrap Script"
    echo "=========================================="
    echo
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                PROJECT_NAME="$2"
                shift 2
                ;;
            -s|--stack)
                STACK="$2"
                shift 2
                ;;
            -d|--description)
                DESCRIPTION="$2"
                shift 2
                ;;
            -h|--help)
                echo "Usage: $0 -n <project-name> -s <stack> -d <description>"
                echo
                echo "Options:"
                echo "  -n, --name        Project name (kebab-case)"
                echo "  -s, --stack       Stack (fastapi|nodejs|react|fullstack)"
                echo "  -d, --description Project description"
                echo "  -h, --help        Show this help message"
                echo
                echo "Example:"
                echo "  $0 -n my-awesome-project -s fullstack -d 'My awesome project'"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Validate input
    validate_input
    
    # Run bootstrap steps
    check_dependencies
    create_repository
    setup_project_structure
    setup_environment
    setup_package_files
    setup_docker
    setup_kubernetes
    setup_github_actions
    setup_documentation
    install_dependencies
    create_initial_files
    setup_git
    setup_hooks
    run_tests
    show_completion_message
}

# Run main function
main "$@"

