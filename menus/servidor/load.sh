#!/bin/bash
clear
function preloading(){
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
  unset GLOBAL_TIME
  unset start_time2
}
function executar() {
	arg1=$1
	arg2=$2
	step "${arg1}"
		try ${arg2}
	next
}
function cmd1() {
    sudo apt update -y >/dev/null 2>&1 &
    sudo apt upgrade -y >/dev/null 2>&1 &
}
function app_1(){
  ufw allow 22
  ufw allow 80/tcp 
}
function app_2(){
  ufw allow 443/tcp 
}

log_info "Instalar..."
executar "Step1: " "cmd1"
executar "Configuring UFW: " "app_ufw"

read -n 1 -s -p "Press any key to continue 0"
echo ""

step "Step2: "
try cmd1
try cmd1
next

preloading "sleep 5" "Instalando..." " ${WHITE} Instalado em $GLOBAL_TIME"
