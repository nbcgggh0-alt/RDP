#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo -e '\e[36m'
echo -e '  $$$$$$\                                $$\       $$$$$$$\  $$$$$$$\  $$$$$$$\  '
echo -e ' $$  __$$\                               $$ |      $$  __$$\ $$  __$$\ $$  __$$\ '
echo -e ' $$ /  \__| $$$$$$\  $$\   $$\  $$$$$$\  $$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ |'
echo -e ' $$ |      $$  __$$\ \$$\ $$  |$$  __$$\ $$ |      $$$$$$$  |$$ |  $$ |$$$$$$$  |'
echo -e ' $$ |      $$$$$$$$ | \$$$$  / $$$$$$$$ |$$ |      $$  __$$< $$ |  $$ |$$  ____/ '
echo -e ' $$ |  $$\ $$   ____| $$  $$<  $$   ____|$$ |      $$ |  $$ |$$ |  $$ |$$ |      '
echo -e ' \$$$$$$  |\$$$$$$$\ $$  /\$$\ \$$$$$$$\ $$ |      $$ |  $$ |$$$$$$$  |$$ |      '
echo -e '  \______/  \_______|\__/  \__| \_______|\__|      \__|  \__|\_______/ \__|      '
echo -e '\e[0m'
echo -e "${YELLOW}           >>> Premium Windows VPS Installer by AmirCexi <<<${NC}"
echo -e "Join our Telegram channel: t.me/AmirCexi"
sleep 3

# Install Docker (latest)
echo -e "${CYAN}Installing Docker...${NC}"

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Check Docker Compose plugin
if ! docker compose version &> /dev/null
then
    sudo apt-get install -y docker-compose-plugin
fi

CONFIG_FILE="docker-compose.yml"

# List of available Windows versions
echo -e "${YELLOW}Select Windows Version:${NC}"
echo " 11 (Pro) | 11l (LTSC) | 10 (Pro) | 10l (LTSC) | 2025 (Server)"
read -p "Enter Version Value: " WINDOWS_VERSION
read -p "Enter Windows Username: " WINDOWS_USERNAME
read -s -p "Enter Windows Password: " WINDOWS_PASSWORD
echo ""
read -p "Enter RAM (e.g 4G): " RAM_SIZE
read -p "Enter CPU Cores: " CPU_CORES
read -p "Enter Disk Size (e.g 50G): " DISK_SIZE

# MENGGUNAKAN PORT TINGGI UNTUK KESELAMATAN
cat > $CONFIG_FILE <<EOF
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "$WINDOWS_VERSION"
      USERNAME: "$WINDOWS_USERNAME"
      PASSWORD: "$WINDOWS_PASSWORD"
      RAM_SIZE: "$RAM_SIZE"
      CPU_CORES: "$CPU_CORES"
      DISK_SIZE: "$DISK_SIZE"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - 61006:8006
      - 62345:3389/tcp
      - 62345:3389/udp
    restart: always
    stop_grace_period: 2m
EOF

docker compose up -d

PUBLIC_IP=\$(curl -s ifconfig.me || curl -s icanhazip.com)

echo -e "${GREEN}CEXI RDP Deployed Successfully!${NC}"
echo -e "${CYAN}Installer Web: http://\$PUBLIC_IP:61006${NC}"
echo -e "${CYAN}RDP Address  : \$PUBLIC_IP:62345${NC}"
echo -e "${YELLOW}Support: t.me/AmirCexi${NC}"
