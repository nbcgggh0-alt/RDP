#!/bin/bash

# --- [ COLORAMA DEFINITION ] ---
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'; B='\033[1;34m'
M='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'; NC='\033[0m'

# --- [ DETECT AUTO IP ] ---
# Mengesan IP yang Amir tengah guna sekarang melalui session SSH
DETECTED_IP=$(echo $SSH_CLIENT | awk '{print $1}')

# --- [ ANIMATION: NYAN CAT ] ---
nyan_loading() {
    local duration=3
    local frames=("~-~-~-~-~-^..^" "-~-~-~-~-~^..^" "~-~-~-~-~-^..^")
    for ((i=0; i<duration*10; i++)); do
        echo -ne "\r${M}${frames[i%3]} ${R}L${Y}O${G}G${B}I${M}C ${R}L${Y}O${G}A${B}D${M}I${R}N${Y}G...${NC} "
        sleep 0.1
    done
    echo -e "\n"
}

# --- [ HEADER DESIGN ] ---
clear
echo -e "${B}------------------------------------------------------------${NC}"
echo -e "${W}  CEXI RDP MANAGER v6.0 - ${M}ULTIMATE LOGIC + AUTO IP${NC}"
echo -e "${W}  Author: AmirCexi | Detected IP: ${G}${DETECTED_IP:-N/A}${NC}"
echo -e "${B}------------------------------------------------------------${NC}"

echo -e "${W}[1] Deploy Windows VPS (Auto IP Whitelist)${NC}"
echo -e "${W}[2] Uninstall Windows VPS${NC}"
echo -e "${W}[3] View Live Logs (Docker)${NC}"
echo -e "${W}[4] Update Firewall (New IP)${NC}"
echo -e "${W}[5] Exit${NC}"
echo -e "${B}------------------------------------------------------------${NC}"
read -p "$(echo -e ${C}Pilihan: ${NC})" main_opt

case $main_opt in
    1)
        nyan_loading
        
        # Install Dependencies
        if ! command -v fail2ban-client &> /dev/null; then
            echo -e "${W}[${G}*${W}] ${C}Setup Security: Installing Fail2Ban...${NC}"
            sudo apt update -q && sudo apt install -y fail2ban > /dev/null 2>&1
        fi

        # Senarai Penuh Windows (Full Logic)
        echo -e "\n${Y}Select Windows Version:${NC}"
        echo -e "Value | Version                   | Size"
        echo -e "${B}--------------------------------------${NC}"
        echo "11    | Windows 11 Pro             | 5.4 GB"
        echo "11l   | Windows 11 LTSC            | 4.2 GB"
        echo "11e   | Windows 11 Enterprise      | 5.8 GB"
        echo "10    | Windows 10 Pro             | 5.7 GB"
        echo "10l   | Windows 10 LTSC            | 4.6 GB"
        echo "10e   | Windows 10 Enterprise      | 5.2 GB"
        echo "8e    | Windows 8.1 Enterprise     | 3.7 GB"
        echo "7e    | Windows 7 Enterprise       | 3.0 GB"
        echo "ve    | Windows Vista Enterprise   | 3.0 GB"
        echo "xp    | Windows XP Professional    | 0.6 GB"
        echo "2025  | Windows Server 2025        | 5.0 GB"
        echo "2022  | Windows Server 2022        | 4.7 GB"
        echo "2019  | Windows Server 2019        | 5.3 GB"
        echo "2016  | Windows Server 2016        | 6.5 GB"
        echo "2012  | Windows Server 2012        | 4.3 GB"
        echo "2008  | Windows Server 2008        | 3.0 GB"
        echo "2003  | Windows Server 2003        | 0.6 GB"
        echo -e "${B}--------------------------------------${NC}"
        
        read -p "$(echo -e ${W}Value Version: ${NC})" WIN_VER
        read -p "$(echo -e ${W}RDP Username: ${NC})" WIN_USER
        read -s -p "$(echo -e ${W}RDP Password: ${NC})" WIN_PASS; echo
        read -p "$(echo -e ${W}RAM (eg 8G): ${NC})" RAM
        read -p "$(echo -e ${W}CPU Cores: ${NC})" CORES
        read -p "$(echo -e ${W}Disk Size (eg 100G): ${NC})" DISK

        echo -e "\n${M}[!] CUSTOM PORT SETTINGS${NC}"
        read -p "$(echo -e ${Y}Secret Web Port: ${NC})" P_WEB
        read -p "$(echo -e ${Y}Secret RDP Port: ${NC})" P_RDP
        
        # Fitur Auto IP
        echo -e "\n${M}[!] SECURITY WHITE-LIST${NC}"
        if [ ! -z "$DETECTED_IP" ]; then
            echo -e "${W}IP Anda dikesan: ${G}$DETECTED_IP${NC}"
            read -p "$(echo -e ${Y}Guna IP ini? (y/n): ${NC})" use_auto
            if [ "$use_auto" == "y" ]; then
                MYIP=$DETECTED_IP
            else
                read -p "$(echo -e ${Y}Masukkan IPv4 Manual: ${NC})" MYIP
            fi
        else
            read -p "$(echo -e ${Y}Masukkan IPv4 Whitelist: ${NC})" MYIP
        fi

        # Firewall Lockdown
        echo -ne "${C}[*] Configuring Firewall... ${NC}"
        sudo ufw allow 22/tcp > /dev/null 2>&1
        sudo ufw allow from $MYIP to any port $P_WEB proto tcp
        sudo ufw allow from $MYIP to any port $P_RDP proto tcp
        sudo ufw allow from $MYIP to any port $P_RDP proto udp
        echo "y" | sudo ufw enable > /dev/null 2>&1
        echo -e "${G}DONE${NC}"

        # Docker Compose Generation
        cat > docker-compose.yml <<EOF
services:
  windows:
    image: dockurr/windows
    container_name: windows
    environment:
      VERSION: "$WIN_VER"
      USERNAME: "$WIN_USER"
      PASSWORD: "$WIN_PASS"
      RAM_SIZE: "$RAM"
      CPU_CORES: "$CORES"
      DISK_SIZE: "$DISK"
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - $P_WEB:8006
      - $P_RDP:3389/tcp
      - $P_RDP:3389/udp
    restart: always
EOF

        echo -e "${W}[${G}*${W}] ${C}Deploying Container...${NC}"
        docker compose up -d
        
        IP=$(curl -s ifconfig.me)
        echo -e "\n${G}SYSTEM READY!${NC}"
        echo -e "${B}--------------------------------------------${NC}"
        echo -e "${W} WEB LOGIN : ${C}http://$IP:$P_WEB${NC}"
        echo -e "${W} RDP LOGIN : ${C}$IP:$P_RDP${NC}"
        echo -e "${W} AUTH IP   : ${C}$MYIP${NC}"
        echo -e "${B}--------------------------------------------${NC}"
        echo -e "${Y}Telegram: t.me/AmirCexi${NC}"
        ;;
    2)
        docker compose down && rm docker-compose.yml
        echo -e "${G}Service Cleaned Up.${NC}"
        ;;
    3) docker logs windows -f ;;
    4)
        read -p "IP Baru: " NIP
        read -p "Port Web tadi: " PW
        read -p "Port RDP tadi: " PR
        sudo ufw allow from $NIP to any port $PW proto tcp
        sudo ufw allow from $NIP to any port $PR proto tcp
        sudo ufw allow from $NIP to any port $PR proto udp
        echo -e "${G}Whitelist Updated.${NC}"
        ;;
    *) exit 0 ;;
esac
