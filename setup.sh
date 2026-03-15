#!/bin/bash
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


#titulo "Atualizando1..."
#read -n 1 -s -p "Press any key to continue 1"
#echo ""

log_info "Atualizando2..."
read -n 1 -s -p "Press any key to continue 2"
echo ""

#step "Atualizando3:"
#  	try sudo apt update
#next

esperar2 "ls" "Atualizando..." " ${WHITE} Atualizado!"



# Install the primary software stack
# Note: Ensure the PHP 8.3 repository is added if your distribution does not include it by default.
sudo apt install -y ufw
sudo apt install -y net-tools
sudo apt install -y nginx
sudo apt install -y openssh-server
sudo apt install -y certbot
sudo apt install -y python3-certbot-nginx
sudo apt install -y php8.3-cli
sudo apt install -y php8.3-fpm
sudo apt install -y php8.3-mcrypt
sudo apt install -y curl
sudo apt install -y git
sudo apt install -y nano
sudo apt install -y wget
sudo apt install -y dos2unix

# User pause 2
read -n 1 -s -p "Press any key to continue 2"
echo ""

# Update package lists again
sudo apt update -y

# User pause 3
read -n 1 -s -p "Press any key to continue 3"
echo ""





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

read -n 1 -s -p "Press any key to continue 3"
clear

titulo "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
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
