#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}DNS${NORMAL}
EOM
createMenu "menuDns" "$ENV_VAR_MENU"
addMenuItem "menuDns" "Instalar" showInstalar
addMenuItem "menuDns" "Procurar" showProcurar

function showInstalar(){
	banner "DNS" "Dominios" "Instalar"

  sudo apt-get update
  sudo apt-get -y install git
  sudo apt-get -y install bind-utils
  sudo apt-get -y install telnet
  sudo apt-get -y install whois
  sudo apt-get -y install nc

  echo "alias dg='bash config/dns.sh'" >> ~/.bashrc
  source ~/.bashrc

	reload "return" "menuDns"
	pause
}

function showProcurar(){
	banner "DNS" "Dominios" "Procurar"
  {
    titulo "Qual o dominio?"
    read -e -p "${MAGENTA}Procurar:${NORMAL} " -i "cms.panel-access.xyz" word
    echo -e "Procurou por $word"
	  source config/dns.sh ${word}
	  esperar "sleep 1" "${WHITE}Terminado... "
  } 2>&1 | tee dns_$(date '+%Y-%m-%d').log
  echo -e ""
	reload "return" "menuDns"
	pause
}