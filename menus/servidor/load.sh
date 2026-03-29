#!/bin/bash
function cmd1() {
    log_info "Updating1..."
    sudo apt update -y
    sudo apt upgrade -y
}

function cmd0(){ 
    log_info "Updating2..."
	sleep 3
}
clear

log_info "Instalar..."
step "Step1: "
	try cmd0
	echo ""
	sleep 5
	try cmd1
next	
	
esperar "sleep 5" "Instalando..." " ${WHITE} Instalado em $GLOBAL_TIME"

read -n 1 -s -p "Press final"
echo ""
