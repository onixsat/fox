#  https://sleeplessbeastie.eu/2023/10/30/how-to-install-packages-non-interactively-using-apt/



#!/bin/bash
function esperar2(){
  # Executar e esperar
  # Run the command passed as 1st argument and shows the spinner until this is done
  # @param String $1 the command to run
  # @param String $2 the title to show next the spinner
  # @param var $3 the variable containing the return code
  CINZA="$(tput setaf 8)"
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  CHECK_SYMBOL='\u2713'
  X_SYMBOL='\u2A2F'
  #local __resultvar=$3
  local done=${3:-'Atualizado'}
  local msg=$2

  eval $1 >/tmp/execute-and-wait.log 2>&1 &
  pid=$!
  delay=0.05

  frames=('\u280B' '\u2819' '\u2839' '\u2838' '\u283C' '\u2834' '\u2826' '\u2827' '\u2807' '\u280F')

  echo "$pid" >"/tmp/.spinner.pid"

  tput civis # Hide the cursor, it looks ugly :D
  index=0
  framesCount=${#frames[@]}
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    printf "${YELLOW}${frames[$index]}${NC} ${GREEN}${msg}${NC}"

    let index=index+1
    if [ "$index" -ge "$framesCount" ]; then
      index=0
    fi

    printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    sleep $delay
  done

  echo -e "\b\\r${CHECK_MARK}${CINZA} ${done}!   "
echo -e ""
  #printf " \b\n"
  # Wait the command to be finished, this is needed to capture its exit status
  #wait $!
  #exitCode=$?
  #if [ "$exitCode" -eq "0" ]; then
  #  printf "${CHECK_SYMBOL} ${2}                                                                \b\n"
  #else
  #  printf "${X_SYMBOL} ${2}                                                                \b\n"
  #fi

  # Restore the cursor
  #tput cnorm
  #eval $__resultvar=$exitCode

  read -n 1 -s -p "Press any key to continue 0"
clear
}

# Update system packages
log_info "Updating package lists and upgrading system..."
add "Atualizar" "sudo apt update -y" "1"
add "Atualizar" "sudo apt upgrade -y" "1"

step "Ficheiro data.txt"
    try echo 'This is a test' > data.txt
    #try mv file.txt data.txt
    try echo 'yet another line' >> data.txt
next

#sudo apt --yes -o Dpkg::Options::="--force-confnew" upgrade

# Add PHP PPA BEFORE installing PHP packages
#log_info "Adding Ondrej PHP PPA..."
#sudo add-apt-repository ppa:ondrej/php -y
#sudo apt update -y
read -n 1 -s -p "Press any key to continue 1"
clear

titulo "Instalar pacotes do sistema..."
log_info "Installing required packages..."

start_time2=$(date +%s%3N)
sudo sed -i s/oneiric/precise/ /etc/apt/sources.list
sudo apt-get -qy update
DEBIAN_FRONTEND=noninteractive sudo apt-get -qy install ufw net-tools nginx 2>&1 | tee oi.log

 
#DEBIAN_FRONTEND=noninteractive apt-get install -y \
#    ufw \
#    net-tools \
#    nginx \
#    php8.1-fpm \
#    php8.1-mcrypt \
#    openssh-server \
#    dos2unix \
#    certbot \
#    python3-certbot-nginx \
#    git \
#    iptables-persistent \
#    fail2ban \
#    curl


     end_time2=$(date +%s%3N)
    duration_ms2=$((end_time2 - start_time2))
    echo -e "Execution1: $duration_ms2"
 # >/dev/null 2>&1 &
esperar2 "sleep 5" "Instalando..." " ${WHITE} Instalado!"

#sleep 5
read -n 1 -s -p "Press any key to continue 2"
clear

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

esperar2 "sleep 5" "Configurando..." " ${WHITE} Configurado!"

read -n 1 -s -p "Press any key to continue 4"
clear

# Install Nginx UI
titulo "Instalar pacotes do sistema..."
if ! command -v nginx-ui &> /dev/null; then
    bash -c "$(curl -fsSL https://cloud.nginxui.com/install.sh)" @ install
else
    log_warn "Nginx UI already installed, skipping..."
fi
esperar2 "sleep 5" "Atualizando..." " ${WHITE} Atualizado!"

read -n 1 -s -p "Press any key to continue 5"
clear

titulo "Script complete!"
esperar2 "sleep 5" "..." " ${WHITE} OK!"

read -n 1 -s -p "Press any key to continue 6"
clear
