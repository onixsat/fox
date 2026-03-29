#!/bin/bash

function esperar2(){
  CINZA="$(tput setaf 8)"
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  CHECK_SYMBOL='\u2713'
  X_SYMBOL='\u2A2F'
  local done=${3:-'Atualizado'}
  local msg=$2
  eval $1 >/tmp/execute-and-wait.log 2>&1 &
  pid=$!
  delay=0.05
  frames=('\u280B' '\u2819' '\u2839' '\u2838' '\u283C' '\u2834' '\u2826' '\u2827' '\u2807' '\u280F')
  echo "$pid" >"/tmp/.spinner.pid"
  tput civis
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
  read -n 1 -s -p "Press any key to continue."
  echo ""
  clear
}
function cmd0(){ 
    echo "texto"
	sleep 5
	
}
clear







log_info "Instalar1..."
add "Atualizar" "sudo apt update -y" "1"
esperar "sleep 5" "Instalando..." " ${WHITE} Instalado em $GLOBAL_TIME"


log_info "Installing required packages..."
add "Atualizar" "sudo apt upgrade -y" "1"
esperar2 "sleep 10" "Instalando2..." " ${WHITE} Instalado2! em ${GLOBAL_TIME}"

read -n 1 -s -p "Press final"
echo ""
