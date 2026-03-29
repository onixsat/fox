#!/bin/bash
function cmd1() {
#    echo -n "Updating1..."
    sudo apt update -y >/dev/null 2>&1 &
    sudo apt upgrade -y >/dev/null 2>&1 &
sleep 5
#echo -e ""
}

function cmd0(){ 
#echo ""
 #   echo -n "Updating0..."
#	sudo apt upgrade -y >/dev/null 2>&1 &
#echo -e ""
sleep 5
}
clear

log_info "Instalar..."
step "Step0: "
try cmd0
next

step "Step1: "
try cmd1
next

esperar "sleep 5" "Instalando..." " ${WHITE} Instalado em $GLOBAL_TIME"

read -n 1 -s -p "Press final"
echo ""
