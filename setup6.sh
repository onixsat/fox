#!/bin/bash
# --- Configuration & Safety ---
set -e # Exit on error
set -u # Exit on unset variables

# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root."
   exit 1
fi

function globais(){
version="1.0.0"
WHITE="$(tput setaf 7)"
CYAN="$(tput setaf 6)"
MAGENTA="$(tput setaf 5)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
RED="$(tput setaf 1)"
NORMAL="$(tput sgr0)"
BOLD="$(tput bold)"

RED2='\033[0;31m'
GREEN2='\033[0;32m'
YELLOW2='\033[1;33m'
NC='\033[0m'


BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

tput init
}

globais

titulo(){
  tput init
  titulo=$1
  if [[ $titulo = *[[:digit:]]* ]]; then
    sleep "$titulo"
    titulo=$2
  fi
  echo -e "\n${BLUE}${titulo}${NORMAL}"
  tput init
}

log_info() {
    echo -e "${GREEN2}[INFO]${NC} $1"
}
log_warn() {
    echo -e "${YELLOW2}[WARN]${NC} $1"
}
log_error() {
    echo -e "${RED2}[ERROR]${NC} $1" >&2
}


function add(){
    start_time2=$(date +%s%3N)
    arg1=$1
    arg2=$2
    step "${arg1}"
        if [[ $3 != '' ]]; then
            try ${arg2} >/dev/null 2>&1 &
        else         
           try ${arg2}
        fi
    next
    
    end_time2=$(date +%s%3N)
    duration_ms2=$((end_time2 - start_time2))
    echo -e "Execution: $duration_ms2"
}
get_script_dir(){
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    while [ -L "$SOURCE_PATH" ]; do
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        if [[ $SOURCE_PATH != /* ]]; then
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}
echo_success() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
    echo -n $"  OK  "
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 0
}
echo_failure() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
    echo -n $"FAILED"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
}
echo_passed() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
    echo -n $"PASSED"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
}
echo_warning() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_WARNING
    echo -n $"WARNING"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
} 
step() {
    echo -n "$@"
    STEP_OK=0
    [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
}
try() {
    local BG=
    [[ $1 == -b ]] && { BG=1; shift; }
    [[ $1 == -- ]] && {       shift; }
    if [[ -z $BG ]]; then
        "$@"
    else
        "$@" &
    fi
    local EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
        STEP_OK=$EXIT_CODE
        [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$

        if [[ -n $LOG_STEPS ]]; then
            local FILE=$(readlink -m "${BASH_SOURCE[1]}")
            local LINE=${BASH_LINENO[0]}

            echo "$FILE: line $LINE: Command \`$*' failed with exit code $EXIT_CODE." >> "$LOG_STEPS"
        fi
    fi

    return $EXIT_CODE
}
next() {
    [[ -f /tmp/step.$$ ]] && { STEP_OK=$(< /tmp/step.$$); rm -f /tmp/step.$$; }
    [[ $STEP_OK -eq 0 ]]  && echo_success || echo_failure
    echo

    return $STEP_OK
}

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
  read -n 1 -s -p "Press any key to continue 0"
  clear
}

# --- Functions ---
update_system() {
    log_info "Updating and upgrading system packages..."
    
    add "Atualizar" "sudo apt update -y" "1"
    add "Atualizar" "sudo apt upgrade -y" "1"
    
read -n 1 -s -p "Press any key to continue 1"
echo ""
}
install_all() {
    titulo "Instalar pacotes do sistema..."
    
read -n 1 -s -p "Press any key to continue 2"
echo ""
}
install_php_env() {    echo "Fetching and executing PHP setup script..."
    
}

conf_ufw() {
echo "Configuring UFW..."

read -n 1 -s -p "Press any key to continue 00"
echo ""
esperar2 "ls" "Atualizando..." " ${WHITE} Atualizado!"
clear
}
conf_iptables() {
  titulo "Configuring iptables..."

  
  esperar2 "sleep 5" "Aguarde" " ${WHITE}Configurado!"
  read -n 1 -s -p "Prime uma última vez. "
  echo ""
  clear
}

# --- Execution ---
update_system

install_all

install_php_env


conf_ufw

conf_iptables

echo "Automation completed successfully."











step "Atualizando3:"
  	try sudo apt update
next





