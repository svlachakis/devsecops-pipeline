#!/bin/bash

# setup.sh - DevSecOps Pipeline Setup Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}     DevSecOps Pipeline Setup Script           ${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check Docker
    if command -v docker &> /dev/null; then
        print_message "Docker is installed ($(docker --version))"
    else
        print_error "Docker is not installed. Please install Docker first."
        echo "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check Docker Compose
    if command -v docker-compose &> /dev/null; then
        print_message "Docker Compose is installed ($(docker-compose --version))"
    else
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        echo "Visit: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    # Check Git
    if command -v git &> /dev/null; then
        print_message "Git is installed ($(git --version))"
    else
        print_error "Git is not installed. Please install Git first."
        exit 1
    fi
    
    # Check if running in git repository
    if git rev-parse --is-inside-work-tree &> /dev/null; then
        print_message "Running inside a Git repository"
    else
        print_warning "Not in a Git repository. Initializing..."
        git init
    fi
}

# Create project structure
create_project_structure() {
    echo -e "\n${BLUE}Creating project structure...${NC}"
    
    # Create directories
    mkdir -p .github/workflows
    mkdir -p src/vulnerable-app
    mkdir -p security-reports
    mkdir -p scripts
    mkdir -p docs
    
    print_message "Project directories created"
}

# Setup Git hooks
setup_git_hooks() {
    echo -e "\n${BLUE}Setting up Git hooks...${NC}"
    
    # Create hooks directory if it doesn't exist
    mkdir -p .git/hooks
    
    # Make pre-commit hook executable
    if [ -f ".git/hooks/pre-commit" ]; then
        chmod +x .git/hooks/pre-commit
        print_message "Git pre-commit hook configured"
    else
        print_warning "Pre-commit hook not found. Please create it manually."
    fi
}

# Setup GitHub secrets instructions
setup_github_secrets() {
    echo -e "\n${BLUE}GitHub Secrets Configuration${NC}"
    echo "================================"
    echo "You need to configure the following secrets in your GitHub repository:"
    echo ""
    echo "1. Go to: https://github.com/YOUR_USERNAME/YOUR_REPO/settings/secrets/actions"
    echo ""
    echo "2. Add these secrets:"
    echo "   ${YELLOW}SNYK_TOKEN${NC}"
    echo "   - Get from: https://app.snyk.io/account"
    echo "   - Click 'Account Settings' → 'Auth Token'"
    echo ""
    echo "   ${YELLOW}SONAR_TOKEN${NC}"
    echo "   - Get from: https://sonarcloud.io/"
    echo "   - Sign up with GitHub (FREE)"
    echo "   - My Account → Security → Generate Token"
    echo ""
}

# Create sample environment file
create_env_file() {
    echo -e "\n${BLUE}Creating environment file...${NC}"
    
    cat > .env.example << 'EOF'
# DevSecOps Pipeline Environment Variables

# Snyk Token (https://app.snyk.io/account)
SNYK_TOKEN=your_snyk_token_here

# SonarCloud Token (https://sonarcloud.io/account/security/)
SONAR_TOKEN=your_sonar_token_here

# GitHub Token (automatic in GitHub Actions)
# GITHUB_TOKEN=automatic

# Application Settings
NODE_ENV=development
APP_PORT=3000

# Database Settings
DB_HOST=postgres
DB_USER=vulnerable_user
DB_PASS=vulnerable_pass
DB_NAME=vulnerable_db
DB_PORT=5432

# Security Settings (intentionally weak for testing)
JWT_SECRET=weak_secret_123
ENCRYPTION_KEY=weak_key_456
EOF
    
    if [ ! -f .env ]; then
        cp .env.example .env
        print_message "Created .env file (please update with your tokens)"
    else
        print_warning ".env file already exists"
    fi
}

# Create SQL initialization file
create_init_sql() {
    echo -e "\n${BLUE}Creating database initialization file...${NC}"
    
    cat > init-db.sql << 'EOF'
-- Initialize vulnerable database for testing

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    balance DECIMAL(10, 2) DEFAULT 0.00,
    account_number VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(100) PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    data TEXT,
    expires_at TIMESTAMP
);

-- Insert test data (with weak passwords for testing)
INSERT INTO users (username, password, email, role) VALUES
    ('admin', 'admin123', 'admin@vulnerable.com', 'admin'),
    ('user1', 'password123', 'user1@vulnerable.com', 'user'),
    ('user2', 'qwerty', 'user2@vulnerable.com', 'user'),
    ('test', 'test', 'test@vulnerable.com', 'user');

INSERT INTO accounts (user_id, balance, account_number) VALUES
    (1, 10000.00, 'ACC001'),
    (2, 500.00, 'ACC002'),
    (3, 1500.00, 'ACC003'),
    (4, 100.00, 'ACC004');
EOF
    
    print_message "Database initialization file created"
}

# Create README with instructions
create_readme() {
    echo -e "\n${BLUE}Creating README...${NC}"
    
    if [ ! -f README.md ]; then
        print_message "README.md created in docs/"
    else
        print_warning "README.md already exists"
    fi
}

# Setup local testing
setup_local_testing() {
    echo -e "\n${BLUE}Setting up local testing environment...${NC}"
    echo ""
    echo "To start local testing environment:"
    echo "  ${GREEN}docker-compose up -d${NC}"
    echo ""
    echo "Services will be available at:"
    echo "  • Vulnerable App: ${YELLOW}http://localhost:3000${NC}"
    echo "  • SonarQube: ${YELLOW}http://localhost:9000${NC} (admin/admin)"
    echo "  • OWASP ZAP: ${YELLOW}http://localhost:8090${NC}"
    echo "  • Grafana: ${YELLOW}http://localhost:3001${NC} (admin/admin)"
    echo "  • Prometheus: ${YELLOW}http://localhost:9090${NC}"
}

# Main setup process
main() {
    clear
    
    # Check prerequisites
    check_prerequisites
    
    # Create project structure
    create_project_structure
    
    # Setup git hooks
    setup_git_hooks
    
    # Create environment file
    create_env_file
    
    # Create database init file
    create_init_sql
    
    # Create README
    create_readme
    
    # Show GitHub secrets instructions
    setup_github_secrets
    
    # Setup local testing
    setup_local_testing
    
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}     Setup Complete! 🎉                        ${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Update .env file with your tokens"
    echo "2. Configure GitHub Secrets (see instructions above)"
    echo "3. Push code to GitHub to trigger pipeline"
    echo "4. For local testing: docker-compose up -d"
    echo ""
    echo "For more information, check docs/README.md"
}

# Run main function
main