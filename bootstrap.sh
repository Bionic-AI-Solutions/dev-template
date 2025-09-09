#!/bin/bash

# =============================================================================
# Dev-PyNode Bootstrap Script
# =============================================================================
# This script creates a new project by copying the dev-template and customizing it
# with the specified project name, stack, and description.

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
TEMPLATE_DIR=""
PROJECT_DIR=""

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
    log_info "Checking host dependencies..."
    
    local missing_deps=()
    
    if ! command -v docker &> /dev/null; then
        missing_deps+=("docker")
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        missing_deps+=("docker-compose")
    fi
    
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    fi
    
    # Note: Node.js and Python are not required on host as they run in Docker containers
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing host dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and try again."
        log_info "Note: Node.js and Python will be installed in Docker containers, not on the host."
        exit 1
    fi
    
    log_success "All required host dependencies are installed"
    log_info "Node.js and Python will run in Docker containers"
}

setup_paths() {
    log_info "Setting up project paths..."
    
    # Get the directory where this script is located (template directory)
    TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Set project directory (parent directory of template)
    PROJECT_DIR="$(dirname "$TEMPLATE_DIR")/$PROJECT_NAME"
    
    log_info "Template directory: $TEMPLATE_DIR"
    log_info "Project directory: $PROJECT_DIR"
    
    # Check if project directory already exists
    if [ -d "$PROJECT_DIR" ]; then
        log_error "Project directory already exists: $PROJECT_DIR"
        log_info "Please choose a different project name or remove the existing directory."
        exit 1
    fi
    
    log_success "Paths configured successfully"
}

copy_template() {
    log_info "Copying template to new project directory..."
    
    # Create project directory
    mkdir -p "$PROJECT_DIR"
    
    # Copy all files from template, excluding .git directory
    rsync -av --exclude='.git' --exclude='node_modules' --exclude='__pycache__' --exclude='*.pyc' --exclude='.env' "$TEMPLATE_DIR/" "$PROJECT_DIR/"
    
    log_success "Template copied to $PROJECT_DIR"
}

customize_project() {
    log_info "Customizing project files with project name and details..."
    
    cd "$PROJECT_DIR"
    
    # Replace dev-template with project name in various files
    local files_to_update=(
        "docker-compose.yml"
        "package.json"
        "package-lock.json"
        "README.md"
        ".github/workflows/ci-cd.yml"
        "k8s/base/deployment.yaml"
        "k8s/base/service.yaml"
        "k8s/base/configmap.yaml"
        "k8s/overlays/development/kustomization.yaml"
        "k8s/overlays/staging/kustomization.yaml"
        "k8s/overlays/production/kustomization.yaml"
    )
    
    for file in "${files_to_update[@]}"; do
        if [ -f "$file" ]; then
            log_info "Updating $file..."
            sed -i "s/dev-template/$PROJECT_NAME/g" "$file"
            sed -i "s/dev_pynode_db/${PROJECT_NAME//-/_}_db/g" "$file"
            sed -i "s/Dev-PyNode/$PROJECT_NAME/g" "$file"
            sed -i "s/AI-powered development platform with Node.js and Python backend/$DESCRIPTION/g" "$file"
        fi
    done
    
    # Update .env.example to .env
    if [ -f ".env.example" ]; then
        cp .env.example .env
        sed -i "s/PROJECT_NAME/$PROJECT_NAME/g" .env
        sed -i "s/dev-template/$PROJECT_NAME/g" .env
        log_success "Environment file created"
    fi
    
    # Update any other files that might contain template references
    find . -type f \( -name "*.md" -o -name "*.yml" -o -name "*.yaml" -o -name "*.json" -o -name "*.py" -o -name "*.ts" -o -name "*.js" \) -exec sed -i "s/dev-template/$PROJECT_NAME/g" {} \;
    
    log_success "Project files customized successfully"
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
    
    cd "$PROJECT_DIR"
    
    # Check if GitHub CLI is available
    if command -v gh &> /dev/null; then
        gh repo create "$GITHUB_ORG/$PROJECT_NAME" \
            --description "$DESCRIPTION" \
            --public \
            --source=. \
            --remote=origin \
            --push
        log_success "GitHub repository created and code pushed"
    else
        log_warning "GitHub CLI not found. Please create the repository manually:"
        log_info "Repository URL: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
        log_info "Description: $DESCRIPTION"
        log_info "Visibility: Public"
        log_info "Then run: git remote add origin https://github.com/$GITHUB_ORG/$PROJECT_NAME.git"
        log_info "And push: git push -u origin main"
    fi
}

# These functions are now handled by customize_project()

install_dependencies() {
    log_info "Installing dependencies in Docker containers..."
    
    cd "$PROJECT_DIR"
    
    # Build Docker images to install dependencies
    if [ -f "docker-compose.yml" ]; then
        log_info "Building Docker images with dependencies..."
        docker-compose build --no-cache
        log_success "Docker images built with dependencies"
    else
        log_warning "docker-compose.yml not found, skipping dependency installation"
    fi
    
    # For Node.js projects, also build frontend if it exists
    if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
        log_info "Building frontend Docker image..."
        if [ -f "frontend/Dockerfile" ]; then
            docker build -t "${PROJECT_NAME}-frontend" ./frontend
            log_success "Frontend Docker image built"
        else
            log_warning "Frontend Dockerfile not found, skipping frontend build"
        fi
    fi
    
    # For Python projects, also build backend if it exists
    if [ -d "backend/python" ] && [ -f "backend/python/requirements.txt" ]; then
        log_info "Building Python backend Docker image..."
        if [ -f "backend/python/Dockerfile" ]; then
            docker build -t "${PROJECT_NAME}-python" ./backend/python
            log_success "Python backend Docker image built"
        else
            log_warning "Python backend Dockerfile not found, skipping Python build"
        fi
    fi
    
    # For Node.js backend projects
    if [ -d "backend/nodejs" ] && [ -f "backend/nodejs/package.json" ]; then
        log_info "Building Node.js backend Docker image..."
        if [ -f "backend/nodejs/Dockerfile" ]; then
            docker build -t "${PROJECT_NAME}-nodejs" ./backend/nodejs
            log_success "Node.js backend Docker image built"
        else
            log_warning "Node.js backend Dockerfile not found, skipping Node.js build"
        fi
    fi
}

setup_git() {
    log_info "Setting up Git repository..."
    
    cd "$PROJECT_DIR"
    
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
    
    cd "$PROJECT_DIR"
    
    # Install husky if package.json exists - use Docker to avoid host installation
    if [ -f "package.json" ] && grep -q "husky" package.json; then
        log_info "Installing Git hooks using Docker..."
        docker run --rm -v "$(pwd):/app" -w /app node:18 npm run prepare || log_warning "Git hooks installation failed, but continuing..."
        log_success "Git hooks installed"
    fi
}

create_initial_files() {
    log_info "Creating initial application files..."
    
    cd "$PROJECT_DIR"
    
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
    log_info "Running initial tests in Docker containers..."
    
    cd "$PROJECT_DIR"
    
    # Run tests in Docker containers if they exist
    if [ -f "docker-compose.yml" ]; then
        log_info "Running tests in Docker containers..."
        docker-compose run --rm app npm test || log_warning "Tests failed, but continuing..."
        log_success "Docker container tests completed"
    else
        log_warning "docker-compose.yml not found, skipping tests"
    fi
    
    # For frontend tests
    if [ -d "frontend" ] && [ -f "frontend/package.json" ] && grep -q "test" frontend/package.json; then
        log_info "Running frontend tests..."
        docker run --rm -v "$(pwd)/frontend:/app" -w /app node:18 npm test || log_warning "Frontend tests failed, but continuing..."
    fi
    
    # For Python tests
    if [ -d "backend/python" ] && [ -f "backend/python/requirements.txt" ]; then
        log_info "Running Python tests..."
        docker run --rm -v "$(pwd)/backend/python:/app" -w /app python:3.11 pip install -r requirements.txt && python -m pytest || log_warning "Python tests failed, but continuing..."
    fi
    
    log_success "Initial tests completed"
}

handoff_to_user() {
    log_success "Project bootstrap completed successfully!"
    echo
    echo "=========================================="
    echo "  Project Created: $PROJECT_NAME"
    echo "=========================================="
    echo
    echo "Project location: $PROJECT_DIR"
    echo "GitHub repository: https://github.com/$GITHUB_ORG/$PROJECT_NAME"
    echo
    echo "Next steps:"
    echo "1. Change to the project directory:"
    echo "   cd $PROJECT_DIR"
    echo
    echo "2. Review and customize the configuration files"
    echo "3. Update the .env file with your specific settings"
    echo "4. Start development: docker-compose up -d"
    echo "5. Access the application at http://localhost:3000"
    echo
    echo "Useful commands:"
    echo "- Start development: docker-compose up -d"
    echo "- Run tests: docker-compose run --rm app npm test"
    echo "- Run Python tests: docker-compose run --rm python python -m pytest"
    echo "- Build images: docker-compose build"
    echo "- Deploy to K8s: kubectl apply -k k8s/overlays/development"
    echo
    echo "Note: All dependencies are installed in Docker containers."
    echo "No Node.js or Python installation required on the host system."
    echo
    echo "Documentation: docs/README.md"
    echo
    echo "=========================================="
    echo "  Ready to start development!"
    echo "=========================================="
    echo
    echo "To continue working on this project, run:"
    echo "  cd $PROJECT_DIR"
    echo
}

# show_completion_message() is now replaced by handoff_to_user()

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
    setup_paths
    copy_template
    customize_project
    setup_git
    create_repository
    create_initial_files
    install_dependencies
    setup_hooks
    run_tests
    handoff_to_user
}

# Run main function
main "$@"

