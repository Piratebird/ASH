#!/usr/bin/env bash

# Colors
BOLD_BLUE="\e[1;34m"
BOLD_GREEN="\e[1;32m"
BOLD_CYAN="\e[1;36m"
BOLD_PURPLE="\e[1;35m"
BOLD_RED="\e[1;31m"
WHITE="\e[1;37m"
RESET="\e[0m"

echo -e "${BOLD_PURPLE}"
cat << "EOF"
   ░███      ░██████   ░██     ░██ 
  ░██░██    ░██   ░██  ░██     ░██ 
 ░██  ░██  ░██         ░██     ░██ 
░█████████  ░████████  ░██████████ 
░██    ░██         ░██ ░██     ░██ 
░██    ░██  ░██   ░██  ░██     ░██ 
░██    ░██   ░██████   ░██     ░██ 
EOF
echo -e "${RESET}"
echo -e "${BOLD_CYAN}Welcome to the ASH Installation Wizard!${RESET}\n"

echo -e "How would you like to run ASH?"
echo -e "  ${BOLD_GREEN}1)${RESET} ${WHITE}Docker Container${RESET} (Sandboxed, secure, recommended for cloud hosting)"
echo -e "  ${BOLD_BLUE}2)${RESET} ${WHITE}Native Host${RESET} (Full system access, monitors your actual machine)"
echo ""
read -p "Choose an option [1/2]: " choice

if [ "$choice" == "1" ]; then
    echo -e "\n${BOLD_CYAN}[*] Docker Deployment Selected...${RESET}"
    if ! command -v docker &> /dev/null; then
        echo -e "${BOLD_RED}[!] Docker is not installed on this system.${RESET}"
        echo -e "Please install Docker and Docker Compose, then try again."
        exit 1
    fi
    
    echo -e "${BOLD_BLUE}[*] Building image and starting container...${RESET}"
    docker compose up -d --build
    
    echo -e "\n${BOLD_GREEN}[✔] ASH is now running in Docker!${RESET}"
    echo -e "Access your dashboard at: ${WHITE}http://localhost:8080${RESET}"
    echo -e "To view logs, run: ${WHITE}docker compose logs -f${RESET}"
    
elif [ "$choice" == "2" ]; then
    echo -e "\n${BOLD_CYAN}[*] Native Host Deployment Selected...${RESET}"
    
    OS_NAME=$(uname -s)
    
    if [ "$OS_NAME" != "Darwin" ] && [ "$EUID" -ne 0 ]; then
        echo -e "${BOLD_RED}[!] Native Linux installation requires root privileges to install packages and systemd services.${RESET}"
        echo -e "Please run: ${WHITE}sudo ./setup.sh${RESET}"
        exit 1
    fi
    
    echo -e "${BOLD_BLUE}[*] Installing dependencies...${RESET}"
    if command -v brew &> /dev/null; then
        brew install lighttpd bash curl gettext coreutils
    elif command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y lighttpd bash curl procps iproute2 gettext-base
    elif command -v dnf &> /dev/null; then
        dnf install -y lighttpd bash curl procps-ng iproute gettext
    elif command -v pacman &> /dev/null; then
        pacman -Sy --noconfirm lighttpd bash curl procps-ng iproute2 gettext
    else
        echo -e "${BOLD_RED}[!] Could not detect package manager. Please install lighttpd manually.${RESET}"
    fi
    
    echo -e "${BOLD_BLUE}[*] Making scripts executable...${RESET}"
    chmod +x server.sh cgi-bin/*.sh
    
    if [ "$OS_NAME" != "Darwin" ]; then
        echo ""
        read -p "Do you want to install ASH as a background systemd service? (y/N): " svc_choice
        
        if [[ "$svc_choice" =~ ^[Yy]$ ]]; then
            echo -e "${BOLD_BLUE}[*] Creating systemd service...${RESET}"
            SERVICE_FILE="/etc/systemd/system/ash.service"
            PROJECT_ROOT="$(pwd)"
            
            cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=ASH System Dashboard
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=${PROJECT_ROOT}
ExecStart=/usr/bin/env bash ${PROJECT_ROOT}/server.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

            systemctl daemon-reload
            systemctl enable ash.service
            systemctl restart ash.service
            
            echo -e "\n${BOLD_GREEN}[✔] ASH has been installed natively and is running as a background service!${RESET}"
            echo -e "Access your dashboard at: ${WHITE}http://localhost:8080${RESET}"
            echo -e "To view logs, run: ${WHITE}journalctl -u ash.service -f${RESET}"
            exit 0
        fi
    fi
    
    echo -e "\n${BOLD_GREEN}[✔] Dependencies installed! Starting ASH directly in your terminal...${RESET}"
    echo -e "Access your dashboard at: ${WHITE}http://localhost:8080${RESET}"
    ./server.sh

else
    echo -e "\n${BOLD_RED}[!] Invalid choice. Exiting.${RESET}"
    exit 1
fi
