#!/usr/bin/env bash
read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}Servidor - ${BOLD}${RED}Configuracão${NORMAL}
EOM
 createMenu "menuConfig" "$ENV_VAR_MENU"
 printMenuStrs "menuConfig"
 addMenuItem "menuConfig" "Informacoes" generalsCommands
 addMenuItem "menuConfig" "Go back" loadMenu "menuServidor"
#loadMenu "menuConfig"
#pause
generalsCommands(){
read -r -d '' ENV_CONFIG << EOM
 Menu ${BLUE}Servidor - ${BOLD}${RED}Informacoes${NORMAL}
EOM

createMenu "menuConfig2" "$ENV_CONFIG"
printMenuStrs "menuConfig2"
addMenuItem "menuConfig2" "Go back" 'loadMenu "menuConfig"'

    loadMenu "menuConfig2"
    #reload "return" "menuConfig"
	pause
}