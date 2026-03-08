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

#./etc/init.d/functions



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
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        # Get symlink directory
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        # Resolve symlink target (relative or absolute)
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            # Candidate path is relative, resolve to full path
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    # Get final script directory path from fully resolved source path
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
    # Check for `-b' argument to run command in the background.
    local BG=

    [[ $1 == -b ]] && { BG=1; shift; }
    [[ $1 == -- ]] && {       shift; }

    # Run the command.
    if [[ -z $BG ]]; then
        "$@"
    else
        "$@" &
    fi

    # Check if command failed and update $STEP_OK if so.
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
    #printf "%100s |%s\n" ""
    #printf '%*s' $(tput cols) ""
    #tput cup $((LINES-2)) $((COLUMNS-4));echo "[OK]"
    #${BOLD}
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
    max=$((SECONDS + 3))              # add 10 seconds to current count

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

    # This part is to make the cursor not blink on top of the animation while it lasts
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
  # Executar e esperar
  # Run the command passed as 1st argument and shows the spinner until this is done
  # @param String $1 the command to run
  # @param String $2 the title to show next the spinner
  # @param var $3 the variable containing the return code
  CINZA="$(tput setaf 8)"
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  CHECK_SYMBOL='\u2713'
  X_SYMBOL='\u2A2F'
  #local __resultvar=$3
  local done=${3:-'Atualizado'}
  local msg=$2

  eval $1 >/tmp/execute-and-wait.log 2>&1 &
  pid=$!
  delay=0.05

  frames=('\u280B' '\u2819' '\u2839' '\u2838' '\u283C' '\u2834' '\u2826' '\u2827' '\u2807' '\u280F')

  echo "$pid" >"/tmp/.spinner.pid"

  tput civis # Hide the cursor, it looks ugly :D
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
  #printf " \b\n"
  # Wait the command to be finished, this is needed to capture its exit status
  #wait $!
  #exitCode=$?
  #if [ "$exitCode" -eq "0" ]; then
  #  printf "${CHECK_SYMBOL} ${2}                                                                \b\n"
  #else
  #  printf "${X_SYMBOL} ${2}                                                                \b\n"
  #fi

  # Restore the cursor
  #tput cnorm
  #eval $__resultvar=$exitCode
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
        #echo "$i: `tput setaf $i`0123456789abcdef@`tput sgr0`"
        `tput setaf $i` 2>&1 | 
		grep -Eo '\^\[\[[0-9]+m$'
    done
}

function jstrings(){
declare separator="$1";
declare -a args=("${@:2}");
declare result;
printf -v result '%s' "${args[@]/#/$separator}";
printf '%s' "${result:${#separator}}"
}

function draw_spinner(){
    # shellcheck disable=SC1003
    local -a marks=( '/' '-' '\ ' '|' )
    local i=0
    delay=${SPINNER_DELAY:-0.25}
    message=${1:-}
    while :; do
        printf '%s\r' "${marks[i++ % ${#marks[@]}]} ${message}"
        sleep "${delay}"
    done
}

function start_loading(){
    message=${1:-}                                # Set optional message
    draw_spinner "${message}" &                   # Start the Spinner:
    SPIN_PID=$!                                   # Make a note of its Process ID (PID):
    declare -g SPIN_PID
    # shellcheck disable=SC2312
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

        echo "#!/usr/bin/env bash" >&3
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
#     encrypt config/config.sh 12345 delete
    FILE=$1
    PASSPHRASE=$2
    SECURE_DELETE=$3
    ENCRYPTED_FILE="${FILE}.enc"

    # Encrypt the file
    openssl enc -aes-256-cbc -salt -pbkdf2 -iter 10000 -in "$FILE" -out "$ENCRYPTED_FILE" -pass pass:"$PASSPHRASE"

    if [ $? -eq 0 ]; then
        echo "File encrypted successfully: $ENCRYPTED_FILE"
    else
        echo "Encryption failed"
        exit 1
    fi

    # Securely delete the original file if requested
    if [ "$SECURE_DELETE" = "delete" ]; then
        # Overwrite the file with random data
        openssl rand -out "$FILE" $(stat --format=%s "$FILE")
        # Optionally, overwrite multiple times for extra security

        # Remove the file
       # rm -f "$FILE"

        if [ $? -eq 0 ]; then
            echo "Original file securely deleted."
        else
            echo "Failed to securely delete the original file."
            exit 1
        fi
    fi
}
function decrypt(){
    #bash libs/decrypt.sh config/config.sh.enc 12345
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 <file to decrypt> <passphrase>"
        exit 1
    fi

    ENCRYPTED_FILE=$1
    PASSPHRASE=$2
    DECRYPTED_FILE="${ENCRYPTED_FILE%.enc}"

    # Decrypt the file with PBKDF2 and the specified number of iterations
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
    countdown && printf "%s\n" "DONE changing to "${1} # Gives out if return is 0 (${?})
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
         # Here you can clean up or do what to do at zero count
         printf "\n"
         unset i
         unset spinner
         return 0 # Can be used in ${?} from parent bash
       else
        i=$((${i}-1))
      fi
    done
   done
  return 1 # Should never be executed
  fi
}
all(){
  #echo -e "\\r${WHITE}${CHECK_MARK} Atualizado!"
  #banner 2 "Servidor" "Configuracão" "Password"
  #read -p "Continuando...." -t 5
  texto(){
    Comandos de modo de texto
    tput bold # Selecionar modo negrito
    tput dim # Selecionar modo de brilho reduzido
    tput smul # Ativar modo de sublinhado
    tput rmul # Desativar modo de sublinhado
    tput rev # Ativar modo de vídeo invertido
    tput smso # Entrar no modo destacado (negrito)
    tput rmso # Sair do modo destacado
    Comandos de movimentação de cursor
    tput cup Y X # Mover o cursor para a posição X,Y da tela (canto superior esquerdo é 0,0)
    tput cuf N # Mover N caracteres para frente (direita)
    tput cub N # Mover N caracteres para trás (esquerda)
    tput cuu N # Mover N linhas para cima
    tput ll # Mover para a última linha, primeira coluna (se não houver cup)
    tput sc # Salvar a posição do cursor
    tput rc # Restaurar a posição do cursor
    tput lines # Mostrar o número de linhas do terminal
    tput cols # Mostrar o número de colunas do terminal
    Comandos de limpeza e inserção
    tput ech N # Apagar N caracteres
    tput clear # Limpar a tela e mover o cursor para 0,0
    tput el 1 # Limpar até o início da linha
    tput el # Limpar até o final da linha
    tput ed # Limpar até o final da tela
    tput ich N # Inserir N caracteres (move o resto da linha para frente!)
    tput il N # Inserir N linhas
    Outros comandos
    tput sgr0 # Restaurar o formato de texto para o padrão do terminal
    tput bel # Emitir um sinal sonoro
  }
  join_strings () {
      declare separator="$1";
      declare -a args=("${@:2}");
      declare result;
      printf -v result '%s' "${args[@]/#/$separator}";
      printf '%s' "${result:${#separator}}"
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
#!/usr/bin/env bash
function sayhello(){
	local n=${@-"anonymous person"}

	#dialog --title "Hello" --clear --msgbox "Hello ${n}, let us be friends!" 10 41
	whiptail --title "titulo" --inputbox "[!] Qual a password?" 10 60
}
OUTPUT="/tmp/input.txt"
# create empty file
>$OUTPUT

dialog --title "t1" \
--backtitle "t2" \
--inputbox "Enter name " 8 60 2>$OUTPUT
respose=$? # get respose
name=$(<$OUTPUT) # get data stored in $OUPUT using input redirection
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
