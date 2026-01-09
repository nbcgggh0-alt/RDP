#!/bin/bash

# --- [ COLORAMA DEFINITION ] ---
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'; B='\033[1;34m'
M='\033[1;35m'; C='\033[1;36m'; W='\033[1;37m'; NC='\033[0m'

# --- [ DETECT IP ] ---
DETECTED_IP=$(echo $SSH_CLIENT | awk '{print $1}')
MY_SERVER_IP=$(curl -s ifconfig.me)

# --- [ HEADER ] ---
show_header() {
    clear
    echo -e "${C}"
    echo '      ██████╗███████╗██╗  ██╗██╗███████╗████████╗ ██████╗ ██████╗'
    echo '     ██╔════╝██╔════╝╚██╗██╔╝██║██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗'
    echo '     ██║     █████╗   ╚███╔╝ ██║███████╗   ██║   ██║   ██║██████╔╝'
    echo '     ██║     █████╗   ██╔██╗ ██║╚════██║   ██║   ██║   ██║██╔══██╗'
    echo '     ╚██████╗███████╗██╔╝ ██╗██║███████║   ██║   ╚██████╔╝██║  ██║'
    echo '      ╚═════╝╚══════╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝'
    echo -e "      ${W}HIGH SPEC EDITION (DO AMD) - v8.0${NC}"
    echo -e "${B}------------------------------------------------------------${NC}"
    echo -e "Host: ${W}DigitalOcean Premium AMD${NC} | RAM: ${W}16GB${NC} | Cores: ${W}8${NC}"
    echo -e "${B}------------------------------------------------------------${NC}"
}

# --- [ INSTALL DOCKER AUTOMATICALLY ] ---
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${Y}[!] Docker tak jumpa. Sedang install Docker rasmi...${NC}"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        echo -e "${G}[✓] Docker berjaya diinstall!${NC}"
        rm get-docker.sh
    else
        echo -e "${G}[✓] Docker dah ada.${NC}"
    fi
}

# --- [ MAIN MENU ] ---
show_header
check_docker
echo -e "${W}[1] Deploy Windows (Auto KVM Check)${NC}"
echo -e "${W}[2] Delete/Reset Windows${NC}"
echo -e "${W}[3] Tengok Logs (Monitor Install)${NC}"
echo -e "${W}[4] Update Firewall IP${NC}"
echo -e "${B}------------------------------------------------------------${NC}"
echo -ne "${Y}Pilihan: ${NC}"; read opt

case $opt in
    1)
        # Check Dependencies
        if ! command -v fail2ban-client &> /dev/null; then
            echo -e "${C}Installing Security Tools...${NC}"
            sudo apt update -q && sudo apt install -y fail2ban > /dev/null 2>&1
        fi

        # Senarai Windows
        echo -e "\n${Y}Pilih Version Windows:${NC}"
        echo -e "11  : Windows 11 Pro (Berat tapi Canggih)"
        echo -e "10  : Windows 10 Pro (Stabil)"
        echo -e "tin : Tiny 11 (Paling Laju/Ringan)"
        echo -e "2022: Windows Server 2022"
        echo -ne "${W}Taip kod (cth: 11): ${NC}"; read WIN_VER
        
        echo -ne "${W}Set Username RDP: ${NC}"; read WIN_USER
        echo -ne "${W}Set Password RDP: ${NC}"; read -s WIN_PASS; echo
        
        # Suggestion for DO Premium
        echo -e "\n${M}[!] Setting Hardware (DO AMD 8 Core)${NC}"
        echo -ne "${W}RAM (Recommend 12G): ${NC}"; read RAM
        echo -ne "${W}Cores (Recommend 6): ${NC}"; read CORES
        echo -ne "${W}Disk (Recommend 64G): ${NC}"; read DISK

        echo -e "\n${M}[!] Setting Port (Nombor 5 Digit)${NC}"
        echo -ne "${Y}Port Web (cth 20080): ${NC}"; read P_WEB
        echo -ne "${Y}Port RDP (cth 20089): ${NC}"; read P_RDP
        
        # Whitelist Logic
        if [ ! -z "$DETECTED_IP" ]; then
            echo -ne "${Y}Whitelist IP anda ($DETECTED_IP)? (y/n): ${NC}"; read use_auto
            if [ "$use_auto" == "y" ]; then MYIP=$DETECTED_IP; else echo -ne "Masukkan IP Manual: "; read MYIP; fi
        else
            echo -ne "Masukkan IP Manual: "; read MYIP
        fi

        # Firewall
        echo -ne "${C}[*] Setup Firewall... ${NC}"
        sudo ufw allow 22/tcp > /dev/null 2>&1
        sudo ufw allow from $MYIP to any port $P_WEB proto tcp
        sudo ufw allow from $MYIP to any port $P_RDP proto tcp
        sudo ufw allow from $MYIP to any port $P_RDP proto udp
        echo "y" | sudo ufw enable > /dev/null 2>&1
        echo -e "${G}DONE${NC}"

        # KVM Check Logic
        echo -e "${W}[*] Checking KVM (Virtualization)...${NC}"
        docker rm -f windows > /dev/null 2>&1
        
        if [ -e /dev/kvm ]; then
            echo -e "${G}🔥 KVM DIKESAN! Performance Maksimum.${NC}"
            DEVICE_FLAG="--device /dev/kvm"
        else
            echo -e "${R}⚠️ KVM TIADA. Guna Software Mode (CPU mungkin tinggi sikit).${NC}"
            DEVICE_FLAG=""
        fi

        echo -e "${W}[*] Sedang Deploy Windows... Sila tunggu.${NC}"
        
        docker run -d \
          --name windows \
          --cap-add NET_ADMIN \
          $DEVICE_FLAG \
          -p $P_WEB:8006 \
          -p $P_RDP:3389 \
          -p $P_RDP:3389/udp \
          -e VERSION="$WIN_VER" \
          -e USERNAME="$WIN_USER" \
          -e PASSWORD="$WIN_PASS" \
          -e RAM_SIZE="$RAM" \
          -e CPU_CORES="$CORES" \
          -e DISK_SIZE="$DISK" \
          --restart always \
          dockurr/windows

        echo -e "\n${G}✅ SIAP DEPLOY! Tunggu 5-10 minit untuk install.${NC}"
        echo -e "${B}------------------------------------------------------------${NC}"
        echo -e "Web Monitor : ${C}http://$MY_SERVER_IP:$P_WEB${NC}"
        echo -e "RDP Address : ${C}$MY_SERVER_IP:$P_RDP${NC}"
        echo -e "Login User  : ${C}$WIN_USER${NC}"
        echo -e "Login Pass  : ${C}$WIN_PASS${NC}"
        echo -e "${B}------------------------------------------------------------${NC}"
        ;;
    2)
        docker rm -f windows
        echo -e "${G}Windows dipadam.${NC}"
        ;;
    3) docker logs -f windows ;;
    4)
        echo -ne "Masukkan IP Baru: "; read NIP
        echo -ne "Port Web tadi: "; read PW
        echo -ne "Port RDP tadi: "; read PR
        sudo ufw allow from $NIP to any port $PW proto tcp
        sudo ufw allow from $NIP to any port $PR proto tcp
        sudo ufw allow from $NIP to any port $PR proto udp
        sudo ufw reload
        echo -e "${G}Whitelist Updated!${NC}"
        ;;
    *) exit 0 ;;
esac

