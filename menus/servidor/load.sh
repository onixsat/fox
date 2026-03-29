#!/bin/bash
function executar() {
	arg1=$1
	arg2=$2
	step "${arg1}"
		try ${arg2} >/dev/null 2>&1 &
	next
}
function app_0() {
    sudo apt update -y
    sudo apt upgrade -y
}

function app_1(){
  ufw allow 80/tcp 
}
function app_2(){
  ufw allow 443/tcp 
}

log_info "Instalar..."
executar "Step0: " "app_0"
executar "Step1: " "app_1"
executar "Step2: " "app_2"

#echo "${CINZA}Processos realizados em $GLOBAL_TIME segundos"
