#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="ravens-roost.xyz"
API_SUBDOMAIN="api.ravens-roost.xyz"
APP_SUBDOMAIN="app.ravens-roost.xyz"

echo -e "${GREEN}Starting deployment for ${DOMAIN}...${NC}"

# Update system
echo -e "${GREEN}Updating system packages...${NC}"
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker and Docker Compose
echo -e "${GREEN}Installing Docker and Docker Compose...${NC}"
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-compose
sudo usermod -aG docker $USER

# Install Node.js (for Astro)
echo -e "${GREEN}Installing Node.js...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g yarn

# Create directory structure
echo -e "${GREEN}Creating directory structure...${NC}"
mkdir -p ~/roost/{frontend,backend,elasticsearch,caddy}

# Create docker-compose.yml
echo -e "${GREEN}Creating Docker Compose configuration...${NC}"
cat > ~/roost/docker-compose.yml << EOL
version: '3.8'

services:
  frontend:
    build: ./frontend
    container_name: roost-frontend
    environment:
      - NODE_ENV=production
    restart: unless-stopped
    labels:
      - "traefik.enable=true"

  backend:
    build: ./backend
    container_name: roost-backend
    environment:
      - RAILS_ENV=production
      - DATABASE_URL=postgres://postgres:\${DB_PASSWORD}@db:5432/roost_production
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - RAILS_MASTER_KEY=\${RAILS_MASTER_KEY}
    depends_on:
      - db
      - elasticsearch
    restart: unless-stopped

  db:
    image: postgres:14-alpine
    container_name: roost-postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=\${DB_PASSWORD}
      - POSTGRES_DB=roost_production
    restart: unless-stopped

  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.11.1
    container_name: roost-elasticsearch
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
      - xpack.security.enabled=false
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    restart: unless-stopped

  caddy:
    image: caddy:2-alpine
    container_name: roost-caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./caddy/Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - frontend
      - backend
    restart: unless-stopped

volumes:
  postgres_data:
  elasticsearch_data:
  caddy_data:
  caddy_config:
EOL

# Create Caddyfile
echo -e "${GREEN}Creating Caddy configuration...${NC}"
mkdir -p ~/roost/caddy
cat > ~/roost/caddy/Caddyfile << EOL
${API_SUBDOMAIN} {
    reverse_proxy backend:3000
}

${APP_SUBDOMAIN} {
    reverse_proxy frontend:4321
}
EOL

# Create environment file
echo -e "${GREEN}Creating environment file...${NC}"
cat > ~/roost/.env << EOL
DB_PASSWORD=$(openssl rand -base64 32)
RAILS_MASTER_KEY=$(openssl rand -base64 32)
EOL

# Create deployment script for updating the application
cat > ~/roost/update.sh << 'EOL'
#!/bin/bash
set -e

echo "Pulling latest changes..."
cd ~/roost/frontend && git pull
cd ~/roost/backend && git pull

echo "Rebuilding containers..."
docker-compose build

echo "Restarting services..."
docker-compose up -d

echo "Running database migrations..."
docker-compose exec backend rails db:migrate

echo "Reindexing Elasticsearch..."
docker-compose exec backend rails elasticsearch:reindex

echo "Update completed successfully!"
EOL
chmod +x ~/roost/update.sh

# Create initialization script for the Rails app
cat > ~/roost/init-rails.sh << 'EOL'
#!/bin/bash
set -e

echo "Setting up Rails database..."
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
docker-compose exec backend rails db:seed

echo "Setting up Elasticsearch indices..."
docker-compose exec backend rails elasticsearch:setup
docker-compose exec backend rails elasticsearch:reindex

echo "Rails initialization completed!"
EOL
chmod +x ~/roost/init-rails.sh

# Create health check script
cat > ~/roost/health-check.sh << EOL
#!/bin/bash

echo "Checking services health..."
docker-compose ps

echo -e "\nChecking Elasticsearch:"
curl -s http://localhost:9200/_cluster/health | grep -o '"status":"[^"]*"'

echo -e "\nChecking PostgreSQL:"
docker-compose exec db pg_isready

echo -e "\nChecking Rails API:"
curl -I http://${API_SUBDOMAIN}

echo -e "\nChecking Frontend:"
curl -I http://${APP_SUBDOMAIN}
EOL
chmod +x ~/roost/health-check.sh

echo -e "${GREEN}Deployment script created successfully!${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Update your domain DNS settings:"
echo "   Add A records for ${API_SUBDOMAIN} and ${APP_SUBDOMAIN} pointing to your server IP"
echo "2. Clone your repositories:"
echo "   git clone <frontend-repo> ~/roost/frontend"
echo "   git clone <backend-repo> ~/roost/backend"
echo "3. Start the services:"
echo "   cd ~/roost && docker-compose up -d"
echo "4. Initialize the Rails application:"
echo "   ./init-rails.sh"
echo "5. Monitor the health of your services:"
echo "   ./health-check.sh"

# Instructions for DNS setup
echo -e "\n${GREEN}DNS Setup Instructions:${NC}"
echo "1. Go to your domain registrar's DNS settings"
echo "2. Add the following A records:"
echo "   ${API_SUBDOMAIN} -> $(curl -s ifconfig.me)"
echo "   ${APP_SUBDOMAIN} -> $(curl -s ifconfig.me)"
echo "3. Wait for DNS propagation (can take up to 48 hours)"