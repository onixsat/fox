#!/bin/bash

BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
echo_success() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
    echo -n $"  OK  "
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 0
}
echo_failure() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
    echo -n $"FAILED"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
}
echo_passed() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
    echo -n $"PASSED"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
}
echo_warning() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
    echo -n $"WARNING"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
} 
step() {
    echo -n "$@"
    STEP_OK=0
    [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
}
try() { # Check for `-b' argument to run command in the background.
    local BG=
    [[ $1 == -b ]] && { BG=1; shift; }
    [[ $1 == -- ]] && {       shift; }
    # Run the command.
    if [[ -z $BG ]]; then
        "$@"
    else
        "$@" &
    fi
    # Check if command failed and update $STEP_OK if so.
    local EXIT_CODE=$?

    if [[ $EXIT_CODE -ne 0 ]]; then
        STEP_OK=$EXIT_CODE
        [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$

        if [[ -n $LOG_STEPS ]]; then
            local FILE=$(readlink -m "${BASH_SOURCE[1]}")
            local LINE=${BASH_LINENO[0]}

            echo "$FILE: line $LINE: Command \`$*' failed with exit code $EXIT_CODE." >> "$LOG_STEPS"
        fi
    fi

    return $EXIT_CODE
}
next() {
    [[ -f /tmp/step.$$ ]] && { STEP_OK=$(< /tmp/step.$$); rm -f /tmp/step.$$; }
    [[ $STEP_OK -eq 0 ]]  && echo_success || echo_failure
    echo -e ""
    return $STEP_OK
}
function add(){
    start_time2=$(date +%s%3N)
    
    arg1=$1
    arg2=$2
    step "${arg1}"
        if [[ $3 != '' ]]; then
            try ${arg2} >/dev/null 2>&1 &
        else         
           try ${arg2}
        fi
    next
    
    end_time2=$(date +%s%3N)
    duration_ms2=$((end_time2 - start_time2))
    echo -e "Execution: $duration_ms2"
}
add "Atualizar" "sudo apt update" "1"
read -n 1 -s -p "Press any key to continue 1"
#add "Atualizar" "sudo apt update"
#read -n 1 -s -p "Press any key to continue 2"
#add "Instalar dnf" "sudo apt install dnf" "1"
#read -n 1 -s -p "Press any key to continue 3"
#add "Instalar dos2unix" "sudo apt install dos2unix -y" "1"
#read -n 1 -s -p "Press any key to continue 4 "
#add "Instalar nginx" "sudo apt install nginx nginx-full -y" "1"
#add "Instalar ufw" "sudo apt install ufw -y" "1"
#add "Instalar iptables" "sudo apt install iptables-persistent -y" "1"
#step "Ficheiro data.txt"
#    try echo 'This is a test' > data.txt
    #try mv file.txt data.txt
#    try echo 'yet another line' >> data.txt
#next


get_script_dir(){
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        # Get symlink directory
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        # Resolve symlink target (relative or absolute)
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            # Candidate path is relative, resolve to full path
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    # Get final script directory path from fully resolved source path
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}

echo "get_script_dir: $(get_script_dir)"
exit

set -eu #set -euo pipefail
TIMEZONE=Africa/Lagos
export LC_ALL=en_US.UTF-8
add-apt-repository --yes universe
timedatectl set-timezone ${TIMEZONE} 
apt --yes install locales-all

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}
cleanup() {
    local code=$?
    if [ $code -ne 0 ]; then
        log_error "Script failed with exit code $code at line $LINENO"
    fi
    echo $code
}
trap cleanup ERR
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

log_info "Starting VPS setup for vps-3026dd85.vps.ovh.net..."
# Update system packages
log_info "Updating package lists and upgrading system..."
sudo apt update -y
sudo apt upgrade -y
sudo apt --yes -o Dpkg::Options::="--force-confnew" upgrade

# Add PHP PPA BEFORE installing PHP packages
log_info "Adding Ondrej PHP PPA..."
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y

#titulo "Instalar pacotes do sistema..."
log_info "Installing required packages..."
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ufw \
    net-tools \
    nginx \
    php8.1-fpm \
    php8.1-mcrypt \
    openssh-server \
    dos2unix \
    certbot \
    python3-certbot-nginx \
    git \
    iptables-persistent \
    fail2ban \
    curl

echo "Pacotes instalados!"
#esperar "sleep 5" "${WHITE}completo! "

read -s -n 1 -p "Press any key to continuar 2!"

# Configure UFW (Uncomplicated Firewall)
log_info "Configuring UFW..."
ufw allow 22
ufw allow 80/tcp 
ufw allow 443/tcp 
ufw allow 21/tcp 
ufw allow 8080/tcp 
ufw allow 8443/tcp 
ufw allow 9000/tcp 
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

log_info "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 9000 -j ACCEPT

read -s -n 1 -p "Press any key to continuar 3!"

SPTH='/home/ubuntu/linux/menus/servidor/'

# Obtain SSL certificate
log_info "Obtaining SSL certificate for cloudflare..."
sudo cp /home/ubuntu/linux/menus/servidor/ssl/ospro.pt.pem /etc/ssl/certs/
sudo cp /home/ubuntu/linux/menus/servidor/ssl/ospro.pt.key /etc/ssl/private/
sudo chmod 644 /etc/ssl/certs/ospro.pt.pem
sudo chmod 640 /etc/ssl/private/ospro.pt.key

log_info "Obtaining SSL certificate for ospro.pt..."
sudo cp /home/ubuntu/linux/menus/servidor/ssl/fullchain.cer /etc/ssl/certs/fullchain.cer
sudo cp /home/ubuntu/linux/menus/servidor/ssl/private.key /etc/ssl/private/private.key
sudo chmod 644 /etc/ssl/certs/fullchain.cer
sudo chmod 640 /etc/ssl/private/private.key

read -s -n 1 -p "Press any key to continuar 4!"

# Install Nginx UI
log_info "Installing Nginx UI..."
if ! command -v nginx-ui &> /dev/null; then
    bash -c "$(curl -fsSL https://cloud.nginxui.com/install.sh)" @ install
else
    log_warn "Nginx UI already installed, skipping..."
fi

read -s -n 1 -p "Press any key to continuar 5!"

echo "Configurar nginx files..."
if [ -d "/var/www/stream" ] 
then
    echo "Directory /var/www/stream exists." 
    sudo rm -r /var/www/stream
    echo "Directory /var/www/stream removido." 
fi

echo "Copiar nginx files..."
sudo mkdir /var/www/stream
chmod -R 777 /var/www/stream/*
sudo cp /home/ubuntu/linux/menus/servidor/www/stream/* /var/www/stream/
sudo cp /home/ubuntu/linux/menus/servidor/sites-available/* /etc/nginx/sites-available/
sudo cp /home/ubuntu/linux/menus/servidor/sites-enabled/* /etc/nginx/sites-enabled/

echo "Setting secure permissions..."
chown -R www-data:www-data /var/www/stream
chown -R www-data:www-data /var/www/html
chmod -R 777 /var/www/stream/*
chmod -R 777 /var/www/html/*

read -s -n 1 -p "Press any key to continuar 5!"

echo "Testing Nginx configuration..."
nginx -t

read -s -n 1 -p "Press any key to continuar 6!"

# Restart services
log_info "Restarting services..."
systemctl restart nginx
systemctl restart php8.1-fpm

# Start and enable Nginx UI
if systemctl list-unit-files | grep -q nginx-ui; then
    systemctl start nginx-ui
    systemctl enable nginx-ui
    log_info "Nginx UI started and enabled"
else
    log_warn "nginx-ui service not found"
fi
# Final status check
log_info "Performing final status checks..."
systemctl is-active --quiet nginx && log_info "Nginx is running" || log_error "Nginx failed to start"
systemctl is-active --quiet php8.1-fpm && log_info "PHP-FPM is running" || log_error "PHP-FPM failed to start"

if systemctl is-active --quiet nginx-ui 2>/dev/null; then
    log_info "Nginx UI is running"
else
    log_warn "Nginx UI status check failed"
fi

echo "Script complete! Rebooting..." 
read -s -n 1 -p "Press any key to reboot!"
#reboot
systemctl restart nginx





