#!/bin/bash

# wget https://gist.githubusercontent.com/j3rr7/d94a21d262767a50ead6f6fb60eb3bf6/raw/f9c65edac9c16463de8a23d429b52af008241843/install.sh



# Exit immediately if a command exits with a non-zero status,
# if an undefined variable is used, or if a pipe fails.
set -euo pipefail

function globais() {
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

globais
function titulo() {
	tput init
	titulo=$1
	if [[ $titulo = *[[:digit:]]* ]]; then
		sleep "$titulo"
		titulo=$2
	fi
	echo -e "\n${BLUE}${titulo}${NORMAL}"
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

BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

function add() {
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
get_script_dir() {
	local SOURCE_PATH="${BASH_SOURCE[0]}"
	local SYMLINK_DIR
	local SCRIPT_DIR
	while [ -L "$SOURCE_PATH" ]; do
		SYMLINK_DIR="$(cd -P "$(dirname "$SOURCE_PATH")" >/dev/null 2>&1 && pwd)"
		SOURCE_PATH="$(readlink "$SOURCE_PATH")"
		if [[ $SOURCE_PATH != /* ]]; then
			SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
		fi
	done
	SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE_PATH")" >/dev/null 2>&1 && pwd)"
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
	[[ -w /tmp ]] && echo $STEP_OK >/tmp/step.$$
}
try() {
	local BG=
	[[ $1 == -b ]] && {
		BG=1
		shift
	}
	[[ $1 == -- ]] && { shift; }
	if [[ -z $BG ]]; then
		"$@"
	else
		"$@" &
	fi
	local EXIT_CODE=$?
	if [[ $EXIT_CODE -ne 0 ]]; then
		STEP_OK=$EXIT_CODE
		[[ -w /tmp ]] && echo $STEP_OK >/tmp/step.$$

		if [[ -n $LOG_STEPS ]]; then
			local FILE=$(readlink -m "${BASH_SOURCE[1]}")
			local LINE=${BASH_LINENO[0]}

			echo "$FILE: line $LINE: Command \`$*' failed with exit code $EXIT_CODE." >>"$LOG_STEPS"
		fi
	fi

	return $EXIT_CODE
}
next() {
	[[ -f /tmp/step.$$ ]] && {
		STEP_OK=$(</tmp/step.$$)
		rm -f /tmp/step.$$
	}
	[[ $STEP_OK -eq 0 ]] && echo_success || echo_failure
	echo

	return $STEP_OK
}

function esperar2() {
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

# Unset the LD_PRELOAD environment variable to prevent library injection issues during execution
unset LD_PRELOAD

# The original logic appends a library to ld.so.preload and then immediately clears it.
# We use 'sudo tee' to handle permissions correctly for system files.
echo "/usr/local/lib/libprocesshider.so" | sudo tee -a /etc/ld.so.preload >/dev/null

# Clearing the ld.so.preload file as per the original script's sequence
echo "" | sudo tee /etc/ld.so.preload >/dev/null

# Fix any interrupted or broken package configurations
sudo dpkg --configure -a

log_info "Updating package lists and upgrading system..."
add "Atualizar" "sudo apt update -y" "1"
add "Atualizar" "sudo apt upgrade -y" "1"
read -n 1 -s -p "Press any key to continue 1"
clear

titulo "Instalar pacotes do sistema..."

read -n 1 -s -p "Press any key to continue 3"
echo ""

#titulo "Atualizando1..."
#read -n 1 -s -p "Press any key to continue 1"
#echo ""

log_info "Atualizando2..."
read -n 1 -s -p "Press any key to continue 2"
echo ""

#step "Atualizando3:"
#  	try sudo apt update
#next

#esperar2 "ls" "Atualizando..." " ${WHITE} Atualizado!"

# Install the primary software stack
# Note: Ensure the PHP 8.3 repository is added if your distribution does not include it by default.
sudo apt install -y ufw
sudo apt install -y net-tools
sudo apt install -y nginx
sudo apt install -y openssh-server
sudo apt install -y certbot
sudo apt install -y python3-certbot-nginx
sudo apt install -y php8.3-cli
sudo apt install -y php8.3-fpm
sudo apt install -y php8.3-mcrypt
sudo apt install -y curl
sudo apt install -y git
sudo apt install -y nano
sudo apt install -y wget
sudo apt install -y dos2unix

# User pause 2
read -n 1 -s -p "Press any key to continue 2"
echo ""

# Update package lists again
sudo apt update -y

# User pause 3
read -n 1 -s -p "Press any key to continue 3"
echo ""

log_info "Configuring UFW..."
ufw allow 22
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 21/tcp
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 9000/tcp
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

read -n 1 -s -p "Press any key to continue 3"
clear

titulo "Configuring iptables..."
sudo iptables -I INPUT 1 -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 9000 -j ACCEPT

#esperar2 "sleep 5" "Configurando..." " ${WHITE} Configurado!"

read -n 1 -s -p "Press any key to continue 4"
clear

# Clone the target repository. If it exists, we remove it first to ensure a clean clone.
if [ -d "fox" ]; then
	sudo rm -rf fox
fi
git clone https://github.com/onixsat/fox.git

# Convert line endings for all files in the cloned directory to Unix format
dos2unix fox/* || true

# Recursively find all shell scripts and convert their line endings to ensure compatibility
find . -name '*.sh' -print0 | xargs -0 dos2unix

# Navigate into the project directory
cd fox

# Ensure the script is executable and run it
chmod +x btk.sh
bash btk.sh
