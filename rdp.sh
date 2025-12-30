#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
NC='\033[0m'

clear
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
echo -e "Join our Telegram channel: t.me/AmirCexi"
echo -e "------------------------------------------------------------"

echo -e "1) Install Windows RDP"
echo -e "2) Uninstall Windows RDP"
read -p "Pilihan anda: " choice

if [ "$choice" == "2" ]; then
    echo -e "${YELLOW}Uninstalling Windows...${NC}"
    docker compose down && rm docker-compose.yml
    echo -e "${GREEN}Uninstall selesai.${NC}"
    exit 1
fi

# Format List Asal yang Amir nak
echo "Select a Windows version from the list below:"
echo " Value  | Version                   | Size"
echo "--------------------------------------"
echo " 11     | Windows 11 Pro             | 5.4 GB"
echo " 11l    | Windows 11 LTSC            | 4.2 GB"
echo " 11e    | Windows 11 Enterprise      | 5.8 GB"
echo " 10     | Windows 10 Pro             | 5.7 GB"
echo " 10l    | Windows 10 LTSC            | 4.6 GB"
echo " 10e    | Windows 10 Enterprise      | 5.2 GB"
echo " 8e     | Windows 8.1 Enterprise     | 3.7 GB"
echo " 7e     | Windows 7 Enterprise       | 3.0 GB"
echo " ve     | Windows Vista Enterprise   | 3.0 GB"
echo " xp     | Windows XP Professional    | 0.6 GB"
echo " 2025   | Windows Server 2025        | 5.0 GB"
echo " 2022   | Windows Server 2022        | 4.7 GB"
echo " 2019   | Windows Server 2019        | 5.3 GB"
echo " 2016   | Windows Server 2016        | 6.5 GB"
echo " 2012   | Windows Server 2012        | 4.3 GB"
echo " 2008   | Windows Server 2008        | 3.0 GB"
echo " 2003   | Windows Server 2003        | 0.6 GB"

echo "Enter the value for the Windows version you want to use:"
read WINDOWS_VERSION

echo "Enter a username for Windows:"
read WINDOWS_USERNAME

echo "Enter a password for Windows:"
read -s WINDOWS_PASSWORD

echo "Enter RAM size (e.g., 8G):"
read RAM_SIZE

echo "Enter the number of CPU cores (e.g., 4):"
read CPU_CORES

echo "Enter disk size (e.g., 256G):"
read DISK_SIZE

# Config dengan Port Selamat (61006 & 62345)
cat > docker-compose.yml <<EOF
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

PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com)

echo -e "${GREEN}Docker Compose started successfully!${NC}"
echo -e "${CYAN}Web Install: http://$PUBLIC_IP:61006${NC}"
echo -e "${CYAN}RDP Connect: $PUBLIC_IP:62345${NC}"
echo -e "${YELLOW}Support: t.me/AmirCexi${NC}"
