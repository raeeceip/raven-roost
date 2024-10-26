#!/bin/bash

# wsl2_roost_setup.sh - Complete WSL2 setup script for Roost Study Space Finder

# Color codes for prettier output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() { echo -e "${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}==>${NC} $1"; }
print_error() { echo -e "${RED}==>${NC} $1"; }
print_warning() { echo -e "${YELLOW}==>${NC} $1"; }

# Check if running in WSL2
check_wsl2() {
    if ! grep -q "microsoft" /proc/version &> /dev/null; then
        print_error "This script must be run in WSL2"
        print_error "Please install WSL2 first using:"
        print_error "PowerShell (Admin): wsl --install"
        exit 1
    fi

    if [ "$(wslpath 'C:' 2>/dev/null)" = "" ]; then
        print_error "WSL2 is not properly configured"
        exit 1
    fi
}

# Install system dependencies
install_system_dependencies() {
    print_step "Updating system packages..."
    sudo apt-get update
    sudo apt-get upgrade -y

    print_step "Installing system dependencies..."
    sudo apt-get install -y \
        autoconf \
        bison \
        build-essential \
        curl \
        git \
        libdb-dev \
        libffi-dev \
        libgdbm-dev \
        libgdbm6 \
        libncurses5-dev \
        libpq-dev \
        libreadline-dev \
        libreadline6-dev \
        libsqlite3-dev \
        libssl-dev \
        libyaml-dev \
        pkg-config \
        sqlite3 \
        zlib1g-dev
}

# Install Node.js using nvm
install_node() {
    print_step "Installing Node.js..."
    
    # Install nvm if not present
    if [ ! -d "$HOME/.nvm" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        
        # Add nvm to current session
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    fi
    
    # Install Node.js LTS
    nvm install --lts
    nvm use --lts
    
    # Install common global packages
    npm install -g npm@latest
}

# Install and configure RVM with Ruby
install_ruby() {
    print_step "Installing RVM and Ruby..."
    
    # Install RVM if not present
    if ! command -v rvm &> /dev/null; then
        # Install RVM GPG keys
        curl -sSL https://rvm.io/mpapis.asc | gpg --import -
        curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
        
        # Install RVM
        curl -sSL https://get.rvm.io | bash -s stable
        source $HOME/.rvm/scripts/rvm
        
        # Add RVM to shell configuration
        echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc
    fi
    
    # Load RVM
    source $HOME/.rvm/scripts/rvm
    
    # Install Ruby
    rvm install 3.2.2
    rvm use 3.2.2 --default
    
    # Install Bundler
    gem install bundler
}

# Install Rails
install_rails() {
    print_step "Installing Rails..."
    gem install rails -v 7.1.2
}

# Setup project structure
setup_project() {
    print_step "Setting up Roost project..."
    
    # Create project directory
    mkdir -p ~/projects/roost
    cd ~/projects/roost
    
    # Initialize new Rails API
    print_step "Creating Rails API..."
    rails new backend --api --database=sqlite3 \
        --skip-test \
        --skip-action-mailer \
        --skip-action-mailbox \
        --skip-action-text \
        --skip-active-storage \
        --skip-action-cable
    
    cd backend
    
    # Update Gemfile
    print_step "Configuring Gemfile..."
    cat >> Gemfile << EOL

# API and serialization
gem 'rack-cors'
gem 'jsonapi-serializer'
gem 'oj'

# Location and mapping
gem 'geocoder'

# Testing
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pry-rails'
  gem 'dotenv-rails'
end

group :development do
  gem 'annotate'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'brakeman'
  gem 'bullet'
end
EOL
    
    # Install dependencies
    print_step "Installing Ruby dependencies..."
    bundle install
    
    # Generate RSpec configuration
    rails generate rspec:install
    
    # Configure CORS
    print_step "Configuring CORS..."
    cat > config/initializers/cors.rb << EOL
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:4321'
    resource '*',
      headers: :any,
      methods: [:get, :post, :patch, :put, :delete, :options, :head],
      credentials: true
  end
end
EOL
    
    cd ..
    
    # Setup Astro frontend
    print_step "Setting up Astro frontend..."
    npm create astro@latest frontend --template basics --typescript --tailwind --yes
    cd frontend
    
    # Install dependencies
    npm install \
        @astrojs/react \
        @astrojs/tailwind \
        @astrojs/image \
        @astrojs/prefetch \
        react \
        react-dom \
        @types/react \
        @types/react-dom \
        axios \
        leaflet \
        @types/leaflet \
        @headlessui/react \
        lucide-react \
        zustand \
        @tanstack/react-query
    
    # Configure Astro
    cat > astro.config.mjs << EOL
import { defineConfig } from 'astro/config';
import react from '@astrojs/react';
import tailwind from '@astrojs/tailwind';
import prefetch from '@astrojs/prefetch';

export default defineConfig({
  integrations: [
    react(),
    tailwind(),
    prefetch()
  ],
  output: 'hybrid'
});
EOL
    
    # Create project structure
    mkdir -p src/{components,layouts,pages,store,utils,assets}
    mkdir -p src/components/{ui,map,study-spaces}
    
    cd ..
    
    # Create development script
    print_step "Creating development script..."
    cat > dev.sh << EOL
#!/bin/bash

# Trap ctrl-c and call cleanup
cleanup() {
    echo "Stopping servers..."
    kill \$RAILS_PID \$ASTRO_PID 2>/dev/null
    exit 0
}
trap cleanup INT TERM

# Start Rails server
cd backend
echo "Starting Rails server..."
rails server &
RAILS_PID=\$!

# Start Astro dev server
cd ../frontend
echo "Starting Astro dev server..."
npm run dev &
ASTRO_PID=\$!

# Wait for processes
wait
EOL
    
    chmod +x dev.sh
}

# Configure Git
setup_git() {
    print_step "Configuring Git..."
    
    if [ ! -f ~/.gitconfig ]; then
        print_step "Enter your Git configuration:"
        read -p "Name: " git_name
        read -p "Email: " git_email
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        git config --global init.defaultBranch main
        git config --global core.editor "code --wait"
    fi
    
    # Initialize Git repository
    cd ~/projects/roost
    git init
    
    # Create .gitignore
    cat > .gitignore << EOL
# Rails
/backend/.bundle
/backend/log/*
/backend/tmp/*
/backend/db/*.sqlite3
/backend/db/*.sqlite3-*
/backend/storage/*
/backend/.env*

# Node
node_modules/
/frontend/.env*
/frontend/dist
.DS_Store
EOL
}

# Main setup process
main() {
    # Verify we're in WSL2
    check_wsl2
    
    print_step "Starting Roost setup in WSL2..."
    
    # Install system dependencies
    install_system_dependencies
    
    # Install development tools
    install_node
    install_ruby
    install_rails
    
    # Setup project
    setup_project
    
    # Configure Git
    setup_git
    
    print_success "Roost setup complete!"
    print_success "Your development environment is ready:"
    echo -e "${GREEN}  * Rails API: ${NC}http://localhost:3000"
    echo -e "${GREEN}  * Astro frontend: ${NC}http://localhost:4321"
    print_success "To start development servers:"
    echo -e "${BLUE}  cd ~/projects/roost && ./dev.sh${NC}"
}

# Run main setup
main