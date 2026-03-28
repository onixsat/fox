#!/bin/bash

# --- Configuration & Safety ---
set -e # Exit on error
set -u # Exit on unset variables

# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root."
   exit 1
fi

# --- Functions ---
update_system() {
    echo "Updating and upgrading system packages..."
    apt update && apt upgrade -y
    apt install unzip
}

install_php_env() {    echo "Fetching and executing PHP setup script..."
    local script_url="https://raw.githubusercontent.com/onixsat/fox/refs/heads/main/php.sh"
    local temp_script="/tmp/php_setup.sh"
    
    wget -q "$script_url" -O "$temp_script"
    bash "$temp_script"
    rm -f "$temp_script"
}

setup_web_root() {
    local target_dir="/var/www/html"
    echo "Configuring web root at $target_dir..."
    
    mkdir -p "$target_dir"
    cd "$target_dir"
    
    echo "var/www/html/index.php" > index.php
    
    chown -R www-data:www-data "$target_dir"
    chmod -R 777 "$target_dir"
}

# --- Execution ---
update_system
install_php_env
setup_web_root

echo "Automation completed successfully."


sudo rm -R class.sh
wget https://raw.githubusercontent.com/onixsat/fox/refs/heads/main/class.sh
source class.sh

log_info "Updating package lists and upgrading system..."
add "Atualizar" "sudo apt update -y" "1"
add "Atualizar" "sudo apt upgrade -y" "1"
read -n 1 -s -p "Press any key to continue 1"
clear

titulo "Instalar pacotes do sistema..."


read -n 1 -s -p "Press any key to continue 3"
echo ""



log_info "Atualizando2..."
read -n 1 -s -p "Press any key to continue 2"
echo ""

#step "Atualizando3:"
#  	try sudo apt update
#next

esperar2 "ls" "Atualizando..." " ${WHITE} Atualizado!"

sudo apt install -y dos2unix wget nano git curl ufw net-tools nginx openssh-server certbot python3-certbot-nginx php8.3-cli php8.3-fpm php8.3-mcrypt


read -n 1 -s -p "Press any key to continue 3"
echo ""


log_info "Configuring UFW..."
ufw allow 22
#ufw allow 80/tcp 
ufw allow 443/tcp 
ufw allow 21/tcp 
ufw allow 8080/tcp 
ufw allow 8443/tcp 
ufw allow 9000/tcp 
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

read -n 1 -s -p "Press any key to continue 3"
clear

titulo "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
#sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 9000 -j ACCEPT

#esperar2 "sleep 5" "Configurando..." " ${WHITE} Configurado!"

read -n 1 -s -p "Press any key to continue 4"
clear

# Clone the target repository. If it exists, we remove it first to ensure a clean clone.
if [ -d "fox" ]; then
    sudo rm -rf fox
fi
git clone https://github.com/onixsat/fox.git

# Convert line endings for all files in the cloned directory to Unix format
dos2unix fox/* || true

# Recursively find all shell scripts and convert their line endings to ensure compatibility
find . -name '*.sh' -print0 | xargs -0 dos2unix

# Navigate into the project directory
cd fox

# Ensure the script is executable and run it
chmod +x btk.sh
bash btk.sh
