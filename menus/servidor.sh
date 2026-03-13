#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}Servidor${NORMAL}
EOM
createMenu "menuServidor" "$ENV_VAR_MENU"
addMenuItem "menuServidor" "Iniciar" showInativo "Iniciar"
addMenuItem "menuServidor" "Instalar" showInstalar2 "Instalar"
addMenuItem "menuServidor" "Configuracao" loadMenu "menuConfig"

source menus/servidor/config.sh

function showInstalar2(){
banner "Servidor" "$1" "Instalar"
if @confirm 'Confirma que quer instalar?' ; then
source menus/servidor/instalar.sh
else
echo "No"
fi
esperar "sleep 2" "Verificando..." " ${WHITE} PPPPPPPPPPP"
reload "return" "menuServidor"
pause
}
function showInativo(){
banner "Servidor" "$1" "Inátivo"
esperar "sleep 2" "Verificando..." " ${WHITE} Esta opção está inátiva"
reload "return" "menuServidor"
pause
}

