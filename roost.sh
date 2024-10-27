#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="ravens-roost.xyz"
API_DOMAIN="api.ravens-roost.xyz"
APP_DOMAIN="app.ravens-roost.xyz"
REPO_URL="https://github.com/raeeceip/raven-roost.git"

echo -e "${GREEN}Starting Raven's Roost deployment...${NC}"

# Update system
echo -e "${GREEN}Updating system packages...${NC}"
sudo apt-get update && sudo apt-get upgrade -y

# Install required packages
echo -e "${GREEN}Installing required packages...${NC}"
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

# Install Docker for Debian
echo -e "${GREEN}Installing Docker...${NC}"
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Install Caddy
echo -e "${GREEN}Installing Caddy...${NC}"
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt-get update
sudo apt-get install -y caddy

# Clone repository
echo -e "${GREEN}Cloning repository...${NC}"
git clone $REPO_URL /home/$USER/raven-roost
cd /home/$USER/raven-roost



# Final setup
echo -e "${GREEN}Starting services...${NC}"
docker compose up -d

echo -e "${GREEN}Setup complete! Here's your next steps:${NC}"
echo "1. Point your domain DNS A records to this server's IP:"
echo "   $DOMAIN -> $(curl -s ifconfig.me)"
echo "   $APP_DOMAIN -> $(curl -s ifconfig.me)"
echo "   $API_DOMAIN -> $(curl -s ifconfig.me)"
echo "2. Caddy will automatically handle SSL certificates"
echo "3. Monitor the logs wi    th: docker compose logs -f"