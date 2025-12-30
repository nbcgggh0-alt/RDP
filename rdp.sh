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
echo -e "${YELLOW}           >>> Premium Windows VPS Manager by AmirCexi <<<${NC}"
echo -e "------------------------------------------------------------"

echo -e "1) Install Windows RDP"
echo -e "2) Uninstall Windows RDP"
echo -e "3) Check Installation Logs"
echo -e "4) ${GREEN}Update Allowed IP (Jika IP Wifi berubah)${NC}"
echo -e "5) Keluar"
read -p "Pilihan anda: " choice

# ----------------- FUNGSI UPDATE IP -----------------
if [ "$choice" == "4" ]; then
    read -p "Masukkan IPv4 baru anda: " NEW_IP
    echo -e "${CYAN}Mengemaskini Firewall...${NC}"
    # Benarkan IP baru
    sudo ufw allow from $NEW_IP to any port 61006 proto tcp
    sudo ufw allow from $NEW_IP to any port 62345 proto tcp
    sudo ufw allow from $NEW_IP to any port 62345 proto udp
    echo -e "${GREEN}Berjaya! IP $NEW_IP kini dibenarkan access RDP.${NC}"
    exit 1
fi

# ----------------- FUNGSI LOGS -----------------
if [ "$choice" == "3" ]; then
    docker logs windows -f
    exit 1
fi

# ----------------- FUNGSI UNINSTALL -----------------
if [ "$choice" == "2" ]; then
    echo -e "${YELLOW}Uninstalling...${NC}"
    docker compose down && rm docker-compose.yml
    echo -e "${GREEN}Selesai dibuang.${NC}"
    exit 1
fi

if [ "$choice" == "5" ]; then exit 1; fi

# ----------------- FUNGSI INSTALL -----------------
echo "Select a Windows version from the list below:"
echo " Value  | Version                   | Size"
echo "--------------------------------------"
echo " 11     | Windows 11 Pro             | 5.4 GB"
echo " 10     | Windows 10 Pro             | 5.7 GB"
echo " 2022   | Windows Server 2022        | 4.7 GB"
echo " xp     | Windows XP Professional    | 0.6 GB"

echo -e "\n${CYAN}--- Konfigurasi Windows ---${NC}"
read -p "Enter Value Version: " WINDOWS_VERSION
read -p "Enter Username: " WINDOWS_USERNAME
read -s -p "Enter Password: " WINDOWS_PASSWORD
echo ""
read -p "Enter RAM (cth: 4G): " RAM_SIZE
read -p "Enter CPU Cores (cth: 2): " CPU_CORES
read -p "Enter Disk Size (cth: 50G): " DISK_SIZE

echo -e "\n${RED}--- Konfigurasi Firewall IP ---${NC}"
read -p "Masukkan IP Wifi anda sekarang: " USER_IP

# Setup Firewall UFW secara selamat
sudo apt install ufw -y
sudo ufw allow 22/tcp  # Jangan bagi Putty terputus
sudo ufw allow from $USER_IP to any port 61006 proto tcp
sudo ufw allow from $USER_IP to any port 62345 proto tcp
sudo ufw allow from $USER_IP to any port 62345 proto udp
echo "y" | sudo ufw enable

# Buat Config Docker
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

echo -e "\n${GREEN}INSTALL SELESAI!${NC}"
echo -e "${CYAN}RDP Connect: $PUBLIC_IP:62345${NC}"
echo -e "${YELLOW}Tips: Jika Wifi anda restart & RDP tak boleh masuk, jalankan skrip ini & pilih Menu 4.${NC}"
