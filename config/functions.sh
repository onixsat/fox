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
  tput init
}
RED2='\033[0;31m'
GREEN2='\033[0;32m'
YELLOW2='\033[1;33m'
NC='\033[0m'
log_info() {
    echo -e "${GREEN2}[INFO]${NC} $1"
}
log_warn() {
    echo -e "${YELLOW2}[WARN]${NC} $1"
}
log_error() {
    echo -e "${RED2}[ERROR]${NC} $1" >&2
}
cleanup() {
    local code=$?
    if [ $code -ne 0 ]; then
        log_error "Script failed with exit code $code at line $LINENO"
    fi
    echo $code
}
trap cleanup ERR
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi
BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"
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
function banner(){
  tput init
  data1=$1
  if [[ $data1 = *[[:digit:]]* ]]; then
    data1=$1
    sleep "$data1"
    var1=$2
    var2=$3
    var3=$4
  else
    var1=$1
    var2=$2
    var3=$3
  fi
  clear
  if [ -z "$var3" ]
  then
    echo -n "${GREEN}                                                         "
    echo -e "${BLUE}                       Version ${version}${YELLOW} Bash OnixSat 2024"
  else
    echo -n ""
    echo -e "${GREEN}Menu ${var1} ${BLUE}- ${YELLOW}${var2} ${GREEN}> ${BOLD}${RED}${var3}"
  fi
  echo -n "${NORMAL}"
  printf "%45s" " " | tr ' ' '-'
  echo -e "${NORMAL}"
  echo -n "${NORMAL}"
  tput init
}
function reload(){
  tput init
  data1=$1 data2=$2
	echo -n "Press Enter to $data1"
	read response
	loadMenu "$data2"
}
function loading(){
    EraseToEOL=$(tput el)
    max=$((SECONDS + 3))              
    while [ $SECONDS -le ${max} ]
    do
        msg='Atualizando'
        for i in {1..4}
        do
            printf "%s" "${msg}"
            msg='.'
            sleep .2
        done
        printf "\r${EraseToEOL}"
    done
    echo -e "\\r${WHITE}Atualizado!"
    printf "\n"
}
function loading_icon(){
    local load_interval="${1}"
    local loading_message="${2}"
    local elapsed=0
    local loading_animation=( '—' "\\" 'l' 'X' )
    echo -n "${WHITE}${loading_message} "
    tput civis
    trap "tput cnorm" EXIT
    while [ "${load_interval}" -ne "${elapsed}" ]; do
        for frame in "${loading_animation[@]}" ; do
            printf "%s\b" "${frame}"
            sleep 0.25
        done
        elapsed=$(( elapsed + 1 ))
    done
    echo -e "\\r${WHITE}${CHECK_MARK} Atualizado!"
    printf " \b\n"
}
function clearLastLines(){
    local linesToClear=$1
    for (( i=0; i<linesToClear; i++ )); do
        tput cuu 1
        tput el
    done
}
function esperar(){
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
  framesCount=${
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
}
function titulo(){
  tput init
  titulo=$1
  if [[ $titulo = *[[:digit:]]* ]]; then
    sleep "$titulo"
    titulo=$2
  fi
  echo -e "\n${BLUE}${titulo}${NORMAL}"
  tput init
}
function cores() {
    END=200
    for i in $(seq 0 $END); do
        `tput setaf $i` 2>&1 | 
		grep -Eo '\^\[\[[0-9]+m$'
    done
}
function jstrings(){
declare separator="$1";
declare -a args=("${@:2}");
declare result;
printf -v result '%s' "${args[@]/
printf '%s' "${result:${
}
function draw_spinner(){
    local -a marks=( '/' '-' '\ ' '|' )
    local i=0
    delay=${SPINNER_DELAY:-0.25}
    message=${1:-}
    while :; do
        printf '%s\r' "${marks[i++ % ${
        sleep "${delay}"
    done
}
function start_loading(){
    message=${1:-}                                
    draw_spinner "${message}" &                   
    SPIN_PID=$!                                   
    declare -g SPIN_PID
    trap stop_loading $(seq 0 15)
}
function stop_loading(){
    if [[ "${SPIN_PID}" -gt 0 ]]; then
        kill -9 "${SPIN_PID}" > /dev/null 2>&1;
    fi
    SPIN_PID=0
    printf '\033[2K'
}
function configs(){
  globais
  titulo "Configurando o sistema..."
  titulo="Configuracão"
  password="Password+2024"
  sshport="2022"
  domain="encpro.pt"
  hostname="srv.encpro.pt"
  ns1="ns1.encpro.pt"
  ns2="ns2.encpro.pt"
  dns="108.181.199.15"
  ip="108.181.199.15"
  password=$(whiptail --title "$titulo" --inputbox "[!] Qual a password?" 10 60 "$password" 3>&1 1>&2 2>&3)
  sshport=$(whiptail --title "$titulo" --inputbox "[!] Qual a porta ssh?" 10 60 "$sshport" 3>&1 1>&2 2>&3)
  domain=$(whiptail --title "$titulo" --inputbox "[!] Qual o dominio?" 10 60 "$domain" 3>&1 1>&2 2>&3)
  hostname=$(whiptail --title "$titulo" --inputbox "[!] Qual o hostname?" 10 60 "$hostname" 3>&1 1>&2 2>&3)
  ns1=$(whiptail --title "$titulo" --inputbox "[!] Qual o ns1?" 10 60 "$ns1" 3>&1 1>&2 2>&3)
  ns2=$(whiptail --title "$titulo" --inputbox "[!] Qual o ns2?" 10 60 "$ns2" 3>&1 1>&2 2>&3)
  dns=$(whiptail --title "$titulo" --inputbox "[!] Qual o dns?" 10 60 "$dns" 3>&1 1>&2 2>&3)
  ip=$(whiptail --title "$titulo" --inputbox "[!] Qual o ip do dominio?" 10 60 "$ip" 3>&1 1>&2 2>&3)
  start_loading "salvando"
    exec 3<> config/config.sh
        echo "
        echo "password='$password'" >&3
        echo "sshport='$sshport'" >&3
        echo "domain='$domain'" >&3
        echo "hostname='$hostname'" >&3
        echo "ns1='$ns1'" >&3
        echo "ns2='$ns2'" >&3
        echo "dns='$dns'" >&3
        echo "ip='$ip'" >&3
  stop_loading
}
function encrypt(){
    FILE=$1
    PASSPHRASE=$2
    SECURE_DELETE=$3
    ENCRYPTED_FILE="${FILE}.enc"
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 10000 -in "$FILE" -out "$ENCRYPTED_FILE" -pass pass:"$PASSPHRASE"
    if [ $? -eq 0 ]; then
        echo "File encrypted successfully: $ENCRYPTED_FILE"
    else
        echo "Encryption failed"
        exit 1
    fi
    if [ "$SECURE_DELETE" = "delete" ]; then
        openssl rand -out "$FILE" $(stat --format=%s "$FILE")
        if [ $? -eq 0 ]; then
            echo "Original file securely deleted."
        else
            echo "Failed to securely delete the original file."
            exit 1
        fi
    fi
}
function decrypt(){
    if [ "$
        echo "Usage: $0 <file to decrypt> <passphrase>"
        exit 1
    fi
    ENCRYPTED_FILE=$1
    PASSPHRASE=$2
    DECRYPTED_FILE="${ENCRYPTED_FILE%.enc}"
    openssl enc -aes-256-cbc -d -salt -pbkdf2 -iter 10000 -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" -pass pass:"$PASSPHRASE"
    if [ $? -eq 0 ]; then
        echo "File decrypted successfully: $DECRYPTED_FILE"
    else
        echo "Decryption failed"
        exit 1
    fi
}
function proteger(){
  globais
  file="config/config.sh.enc"
  if [[ ! -f "$file" && ! -s "$file" ]]; then
    echo "Não tem o ficheiro encriptado"
    configs
    encrypt config/config.sh 12345 delete
          esperar "sleep 5" "${WHITE}Terminando..." "Configurado!"
    exit 0
  else
    word=$(whiptail --title "Password" --passwordbox "Qual a senha de proteção?" 10 60 "12345" 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      decrypt config/config.sh.enc ${word}
      esperar "sleep 0" "${WHITE}Descodificando..." "Descodificado!"
      data=$(<config/config.sh)
      tmpfile="$(mktemp /tmp/myscript.XXXXXX)"
      cat <<< "$data" > "$tmpfile"
      rm -f "config/config.sh"
      trap 'rm -f "$tmpfile"' SIGTERM SIGINT EXIT
      source "$tmpfile"
      esperar "sleep 0" "${WHITE}Criando $tmpfile..." "Criado o $tmpfile"
      esperar "sleep 0" "${WHITE}Carregando o sistema..." "Carregado!"
      clear
      return 0
    else
      echo "Cancelou a proteção."
      exit 1
    fi
  fi
}
@confirm(){
  local message="$*"
  local result=3
  echo -n "> $message (y/n) " >&2
  while [[ $result -gt 1 ]] ; do
    read -s -n 1 choice
    case "$choice" in
      y|Y ) result=0 ;;
      n|N ) result=1 ;;
    esac
  done
  return $result
}
countdown(){
  cdx(){
    countdown && printf "%s\n" "DONE changing to "${1} 
  }
  spinner=(
  "Working    "
  "Working.   "
  "Working..  "
  "Working... "
  "Working...."
  )
  i=4
  if [ ${i} -lt 5 ]
  then
   while true
    do
     for i in ${i}
      do
       printf "%s    \t" ${spinner[i]}
       sleep .1
       printf "\r"
       sleep .1
       if [ ${i} -eq 0 ]
        then
         printf "\n"
         unset i
         unset spinner
         return 0 
       else
        i=$((${i}-1))
      fi
    done
   done
  return 1 
  fi
}
all(){
  texto(){
    Comandos de modo de texto
    tput bold 
    tput dim 
    tput smul 
    tput rmul 
    tput rev 
    tput smso 
    tput rmso 
    Comandos de movimentação de cursor
    tput cup Y X 
    tput cuf N 
    tput cub N 
    tput cuu N 
    tput ll 
    tput sc 
    tput rc 
    tput lines 
    tput cols 
    Comandos de limpeza e inserção
    tput ech N 
    tput clear 
    tput el 1 
    tput el 
    tput ed 
    tput ich N 
    tput il N 
    Outros comandos
    tput sgr0 
    tput bel 
  }
  join_strings () {
      declare separator="$1";
      declare -a args=("${@:2}");
      declare result;
      printf -v result '%s' "${args[@]/
      printf '%s' "${result:${
  }
  join_strings ' && ' "1" "2" "3"
  function joinArray() {
    local delimiter="${1}"
    local output="${2}"
    for param in ${@:3}; do
      output="${output}${delimiter}${param}"
    done
    echo "${output}"
  }
  joinArray ' && ' "1" "2" "3"
    declare -A myArray
    myArray[A]="1x"
    myArray[B]="ax"
for i in ${!myArray[@]}; do
  echo "element $i is ${myArray[$i]}"
done
oi=$(joinArray ' && ' "${myArray[@]}")
echo "oi $oi"
}
ver(){
function sayhello(){
	local n=${@-"anonymous person"}
	whiptail --title "titulo" --inputbox "[!] Qual a password?" 10 60
}
OUTPUT="/tmp/input.txt"
>$OUTPUT
dialog --title "t1" \
--backtitle "t2" \
--inputbox "Enter name " 8 60 2>$OUTPUT
respose=$? 
name=$(<$OUTPUT) 
case $respose in
  0)
  	sayhello ${name}
  	;;
  1)
  	echo "Cancel pressed."
  	;;
  255)
   echo "[ESC] key pressed."
esac
rm $OUTPUT
}
