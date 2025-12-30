#!/bin/bash

# --- [ COLORAMA DEFINITION ] ---
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'; B='\033[1;34m'
M='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'; NC='\033[0m'

# --- [ DETECT AUTO IP ] ---
DETECTED_IP=$(echo $SSH_CLIENT | awk '{print $1}')

# --- [ ANIMATION: NYAN CAT ] ---
nyan_loading() {
    local duration=3
    local frames=("~-~-~-~-~-^..^" "-~-~-~-~-~^..^" "~-~-~-~-~-^..^")
    for ((i=0; i<duration*10; i++)); do
        echo -ne "\r${M}${frames[i%3]} ${R}L${Y}O${G}A${B}D${M}I${R}N${Y}G ${G}C${B}E${M}X${R}I...${NC} "
        sleep 0.1
    done
    echo -e "\n"
}

# --- [ CEXISTORE ASCII LOGO ] ---
show_header() {
    clear
    echo -e "${C}"
    echo '      ██████╗███████╗██╗  ██╗██╗███████╗████████╗ ██████╗ ██████╗ ███████╗'
    echo '     ██╔════╝██╔════╝╚██╗██╔╝██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗██╔════╝'
    echo '     ██║     █████╗   ╚███╔╝ ██║███████╗   ██║   ██║   ██║██████╔╝█████╗  '
    echo '     ██║     █████╗   ██╔██╗ ██║╚════██║   ██║   ██║   ██║██╔══██╗█████╗  '
    echo '     ╚██████╗███████╗██╔╝ ██╗██║███████║   ██║   ╚██████╔╝██║  ██║███████╗'
    echo '      ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝'
    echo -e "                   ${W}S A L E S   O N L I N E   A N D   C H E A P S${NC}"
    echo -e "${B}----------------------------------------------------------------------------${NC}"
    echo -e "${W}  CEXI RDP MANAGER v7.0 | Detected IP: ${G}${DETECTED_IP:-N/A}${NC}"
    echo -e "${B}----------------------------------------------------------------------------${NC}"
}

# --- [ MAIN MENU ] ---
show_header
echo -e "${W}[1] Deploy Windows VPS (Auto Whitelist)${NC}"
echo -e "${W}[2] Uninstall Windows VPS${NC}"
echo -e "${W}[3] View Live Logs (Docker)${NC}"
echo -e "${W}[4] Update Firewall (Add New IP)${NC}"
echo -e "${W}[5] Exit Terminal${NC}"
echo -e "${B}----------------------------------------------------------------------------${NC}"
echo -ne "${Y}Sila pilih menu: ${NC}"; read opt

case $opt in
    1)
        nyan_loading
        
        # Check Dependencies
        if ! command -v fail2ban-client &> /dev/null; then
            echo -e "${W}[${G}*${W}] ${C}Installing Security: Fail2Ban...${NC}"
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
        
        # FIXED SYNTAX: Gunakan cara echo -ne sebelum read untuk elak ralat subshell
        echo -ne "${W}Value Version: ${NC}"; read WIN_VER
        echo -ne "${W}RDP Username: ${NC}"; read WIN_USER
        echo -ne "${W}RDP Password: ${NC}"; read -s WIN_PASS; echo
        echo -ne "${W}RAM Size (eg 8G): ${NC}"; read RAM
        echo -ne "${W}CPU Cores: ${NC}"; read CORES
        echo -ne "${W}Disk Size (eg 100G): ${NC}"; read DISK

        echo -e "\n${M}[!] CUSTOM PORT SETTINGS${NC}"
        echo -ne "${Y}Secret Web Port: ${NC}"; read P_WEB
        echo -ne "${Y}Secret RDP Port: ${NC}"; read P_RDP
        
        echo -e "\n${M}[!] SECURITY WHITE-LIST${NC}"
        if [ ! -z "$DETECTED_IP" ]; then
            echo -e "${W}IP Anda dikesan: ${G}$DETECTED_IP${NC}"
            echo -ne "${Y}Guna IP ini untuk Whitelist? (y/n): ${NC}"; read use_auto
            if [ "$use_auto" == "y" ]; then
                MYIP=$DETECTED_IP
            else
                echo -ne "${Y}Masukkan IPv4 Manual: ${NC}"; read MYIP
            fi
        else
            echo -ne "${Y}Masukkan IPv4 Whitelist: ${NC}"; read MYIP
        fi

        echo -ne "${C}[*] Configuring Firewall Lockdown... ${NC}"
        sudo ufw allow 22/tcp > /dev/null 2>&1
        sudo ufw allow from $MYIP to any port $P_WEB proto tcp
        sudo ufw allow from $MYIP to any port $P_RDP proto tcp
        sudo ufw allow from $MYIP to any port $P_RDP proto udp
        echo "y" | sudo ufw enable > /dev/null 2>&1
        echo -e "${G}DONE${NC}"

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

        echo -e "${W}[${G}*${W}] ${C}Deploying Container Engine...${NC}"
        docker compose up -d
        
        IP=$(curl -s ifconfig.me)
        echo -e "\n${G}SUCCESS: SYSTEM DEPLOYED!${NC}"
        echo -e "${B}------------------------------------------------------------${NC}"
        echo -e "${W} WEB LOGIN : ${C}http://$IP:$P_WEB${NC}"
        echo -e "${W} RDP LOGIN : ${C}$IP:$P_RDP${NC}"
        echo -e "${W} AUTH IP   : ${C}$MYIP${NC}"
        echo -e "${B}------------------------------------------------------------${NC}"
        echo -e "${Y}Telegram: t.me/AmirCexi${NC}"
        ;;
    2)
        docker compose down && rm docker-compose.yml
        echo -e "${G}Success: Session Removed.${NC}"
        ;;
    3) docker logs windows -f ;;
    4)
        echo -ne "Masukkan IP Baru: "; read NIP
        echo -ne "Port Web tadi: "; read PW
        echo -ne "Port RDP tadi: "; read PR
        sudo ufw allow from $NIP to any port $PW proto tcp
        sudo ufw allow from $NIP to any port $PR proto tcp
        sudo ufw allow from $NIP to any port $PR proto udp
        echo -e "${G}Whitelist Updated for $NIP${NC}"
        ;;
    *) exit 0 ;;
esac
