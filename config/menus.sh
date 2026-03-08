#!/bin/bash
HEADER_MSG="${CYAN}Bash Ubuntu${NORMAL}"

read -r -d '' ENV_VAR_MENU << EOM
${RED}Main Menu${NORMAL}
EOM
createMenu "mainMenu" "$ENV_VAR_MENU"
addMenuItem "mainMenu" "Servidor" loadMenu "menuServidor"
addMenuItem "mainMenu" "Nginx" loadMenu "menuNginx"
addMenuItem "mainMenu" "DNS" loadMenu "menuDns"
addMenuItem "mainMenu" "Quit" l8r

source menus/servidor.sh
source menus/nginx.sh
source menus/dns.sh
