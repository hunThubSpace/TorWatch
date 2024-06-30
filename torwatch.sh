#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[1;34m'
NC='\033[0m' 

check_command() {
    local command_name=$1
    local package_name=$2

    if ! command -v $command_name &> /dev/null; then
        echo -e "${YELLOW}[-] $command_name is not installed${NC}"
        sleep 1
        echo -e "${BLUE}[*] Installing $command_name ... ${NC}"
        sudo apt-get update &> /var/log/torwatch_update.log
        sudo apt-get install -y $package_name &> /var/log/torwatch_install.log
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Failed to install $command_name. Exiting${NC}"
            exit 1
        fi
        echo -e "${GREEN}[*] $command_name Installed ${NC}"
    fi
}

check_tor() {
    if ! command -v tor &> /dev/null; then
        echo -e "${YELLOW}[-] Tor is not installed${NC}"
        sleep 1
        echo -e "${BLUE}[*] Installing Tor service${NC}"
        sudo apt-get update &> /var/log/torwatch_update.log
        sudo apt-get install -y tor &> /var/log/torwatch_install.log
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Failed to install Tor. Exiting${NC}"
            exit 1
        fi
    fi

    if ! systemctl is-active --quiet tor; then
        echo -e "${YELLOW}[-] Tor is not running${NC}"
        sleep 3
        echo -e "${BLUE}[*] Starting Tor service${NC}"
        sudo systemctl start tor
        sudo systemctl enable tor
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Failed to start Tor. Exiting.${NC}"
            exit 1
        fi
        echo -e "${GREEN}[+] Service Tor started and enabled${NC}"
    fi
}

echo ""

check_command "figlet" "figlet"
check_command "toilet" "toilet"
check_command "geoiplookup" "geoip-bin"

check_tor

if [ $# -ne 1 ]; then
    echo -e "${RED}[-] Error in running the script${NC}"
    echo -e "[*] Usage: $0 <website>"
    echo -e "[*] Provide a website like www.google.com, not https://www.google.com"
    exit 1
fi

SITE_URL="$1"
BASE_SITE_NAME=$(echo "$SITE_URL" | sed 's/^https\?:\/\///' | sed 's/^www\.//')

mkdir -p "$BASE_SITE_NAME"

BLOCKED_IP_FILE="$BASE_SITE_NAME/$BASE_SITE_NAME.blocked.txt"
LOG_FILE="$BASE_SITE_NAME/$BASE_SITE_NAME.log"
exec > >(tee -a "$LOG_FILE") 2>&1

touch "$BLOCKED_IP_FILE"

sleep 2
clear

echo ""
figlet -f future "[*] TorWatch [*]"
echo ""


echo -e "${BLUE}[*] Press 'c' to change Tor IP.${NC}"

TOR_SOCKS_PROXY="127.0.0.1:9050"
IDENT_ME_URL="https://ident.me"
GEOIP_COMMAND="geoiplookup"

while true; do
    if read -t 1 -n 1 key && [ "$key" = "c" ]; then
        sudo systemctl restart tor
        if [ $? -eq 0 ]; then
            echo -e "$(date) - ${GREEN}[+] Manually IP changed${NC}"
        else
            echo -e "$(date) - ${RED}[-] Failed to manually change IP.${NC}"
        fi
    fi

    status_code=$(curl --silent --insecure --socks5 $TOR_SOCKS_PROXY "https://$SITE_URL" -I | head -n 1 | cut -d " " -f 2)
    
    if [ "$status_code" != "200" ]; then
        current_ip=$(curl --silent --socks5 $TOR_SOCKS_PROXY $IDENT_ME_URL)
        
        if grep -Fxq "$current_ip" "$BLOCKED_IP_FILE"; then
            echo -e "$(date) - ${RED}Current IP $current_ip is already blocked.${NC}"
        else
            location=$($GEOIP_COMMAND $current_ip 2>/dev/null | awk -F ": " '{print $2}')
            if [ $? -eq 0 ]; then
                echo -e "$(date) - ${RED}Site https://$SITE_URL returned status code $status_code. Blocking IP: ${YELLOW}$current_ip${NC} [${location}]"
                echo "$current_ip - $location" >> "$BLOCKED_IP_FILE"
            else
                echo -e "$(date) - ${RED}Failed to get location for IP $current_ip.${NC}"
            fi
        fi
        
        sudo systemctl restart tor
        echo "$(date) - Tor restarted."
        sleep 5
    else
        current_ip=$(curl --silent --socks5 $TOR_SOCKS_PROXY $IDENT_ME_URL)
        location=$($GEOIP_COMMAND $current_ip 2>/dev/null | awk -F ": " '{print $2}')
        if [ $? -eq 0 ]; then
            echo -e "$(date) - ${GREEN}Site https://$SITE_URL is accessible through Tor. Current IP: ${YELLOW}$current_ip${NC} (${location})"
        else
            echo -e "$(date) - ${RED}Failed to get location for IP $current_ip.${NC}"
        fi
    fi

    # Ensure the blocked IPs file is sorted
    sort -u "$BLOCKED_IP_FILE" -o "$BLOCKED_IP_FILE"

    sleep 5
done
