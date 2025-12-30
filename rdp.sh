#!/bin/bash

# Warna
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
echo -e "Join our Telegram channel: t.me/AmirCexi"
echo -e "------------------------------------------------------------"

echo -e "1) ${GREEN}Install Windows RDP${NC}"
echo -e "2) ${RED}Uninstall Windows RDP${NC}"
echo -e "3) Keluar"
read -p "Sila pilih menu [1-3]: " MAIN_CHOICE

# ----------------- FUNGSI UNINSTALL -----------------
if [ "$MAIN_CHOICE" == "2" ]; then
    echo -e "${YELLOW}Memulakan proses Uninstall...${NC}"
    if [ -f "docker-compose.yml" ]; then
        docker compose down
        rm docker-compose.yml
        echo -e "${GREEN}Windows RDP telah berjaya dibuang!${NC}"
    else
        echo -e "${RED}Fail docker-compose.yml tidak dijumpai. Tiada apa untuk di-uninstall.${NC}"
    fi
    exit 1
fi

if [ "$MAIN_CHOICE" == "3" ]; then
    exit 1
fi

# ----------------- FUNGSI INSTALL -----------------

# Install Docker jika belum ada
echo -e "${CYAN}Memeriksa Docker...${NC}"
if ! command -v docker &> /dev/null; then
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    sudo systemctl enable docker && sudo systemctl start docker
fi

# Senarai Penuh Windows
echo -e "\n${YELLOW}List of available Windows versions:${NC}"
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
echo ""

read -p "Enter Value: " WINDOWS_VERSION
read -p "Enter Username: " WINDOWS_USERNAME
read -s -p "Enter Password: " WINDOWS_PASSWORD
echo ""
read -p "Enter RAM (e.g 4G): " RAM_SIZE
read -p "Enter CPU Cores: " CPU_CORES
read -p "Enter Disk Size (e.g 60G): " DISK_SIZE

# Buat fail Config dengan Port Tinggi (Rahsia)
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

echo -e "\n${GREEN}CEXI RDP Deployed Successfully!${NC}"
echo -e "${CYAN}Web Install (Browser): http://$PUBLIC_IP:61006${NC}"
echo -e "${CYAN}RDP Address (Mobile/PC): $PUBLIC_IP:62345${NC}"
echo -e "${YELLOW}Support: t.me/AmirCexi${NC}"
