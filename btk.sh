#!/bin/bash
{
thisFilePath="$( dirname "${BASH_SOURCE[0]}" )"
source "$thisFilePath/config/pathUtils.sh"
source "$thisFilePath/config/functions.sh"

proteger
srcLibFile "menuUtils.sh"
srcConfigFile "menus.sh"
TRUE=0
FALSE=1
NIL="nil"
ORIG_DIR="$(pwd)"
SCRIPT_DIR="$(getActiveScriptDir)"
BASHRC=~/.bashrc
function main() {
    keepGoing=$TRUE
    cd "$SCRIPT_DIR"
    init

    while keepGoing; do
        loadMenu "mainMenu" || l8r
    done
    cd "$ORIG_DIR"
    resetBashFunctions
    clear
}
function keepGoing() {
    return $keepGoing;
}
function init() {
    HEADER="$HEADER_MSG"
}
function resetBashFunctions() {
    echo "Removing all functions in current shell... Count:"
    declare -F |wc -l
    for line in $(declare -F | cut -d' ' -f3); do unset -f "$line"; done
    echo "Removed. Function Count:"
    declare -F |wc -l
    $BASHRC
    echo "Reset BASHRC; Function Count:"
    declare -F |wc -l
	#echo "Kill tcp 8000:"
	#sudo lsof -t -i tcp:8000 -s tcp:listen | sudo xargs kill
	lsof -nP -iTCP -sTCP:LISTEN | sudo xargs kill
	#sleep 5
}





#find -name '*.sh' -print0 | xargs -0 dos2unix
#set -e
#set -Eeuo pipefail
#set -o errexit
#set -o nounset
#set -o pipefail


function sigint() {
	echo "sigint"
	clear
	exit 0;
}
function sair() {
	echo "sair"
	clear
	exit 0;
}
function notify() {
	echo "" >> notify.log &
	echo -e "$(caller): ${BASH_COMMAND}" >> notify.log
	echo ""
}


check_positive() {
 if (( $1 > 0 )); then
  true  # positive
 else
 	echo "You pressed '$key'"
	echo "${WHITE} Pressionar o botão Enter para continuar."
 fi
}


quit() {
echo "Do you want to quit ? (y/n)"
  read ctrlc
  if [ "$ctrlc" = 'y' ]; then
    return 1
  fi
}



ctrlc_count=0

function no_ctrlc()
{
    let ctrlc_count++
    echo
    if [[ $ctrlc_count == 1 ]]; then
        echo "Stop that."
    elif [[ $ctrlc_count == 2 ]]; then
        echo "Once more and I quit."
    else
        echo "That's it.  I quit."
        exit
    fi
}

function interrupt() {
 
 if (whiptail --title "Confirmar" --yesno "As teclas CTRL+C estáo sendo pressionadas.\nVocê realmente vai querer sair?" --no-button 'Não' --yes-button 'Sim' 9 50); then
 
 	clear
	echo "Adeus!"
	sleep 3
	exit 0
	
else

clear
	tput init
	esperar "sleep 2" "Voltando..." "${WHITE} Voltamos."
	#sleep 2
	echo  ""
	#/bin/bash -c 'echo -ne "\n"'
	#/bin/bash -c 'echo -ne "\n"'
	#read -p "Press any key to continue..." key
	#pause
 
 
 
no_ctrlc



fi


}

#trap sigint SIGINT
#trap sair EXIT
#trap notify ERR
trap 'interrupt' INT

ctrlc_received=0

function handle_ctrlc()
{
    echo
    if [[ $ctrlc_received == 0 ]]
    then
        echo "I'm hmmm... running. Press Ctrl+C again to stop!"
		ctrlc_received=1
		#return 1
		sleep 2
		reload "return" "mainMenu"
		#$(( ctrlc_received + 1 ))
    else
        echo "It's all over!"
        exit
    fi
}

# trapping the SIGINT signal
#trap handle_ctrlc SIGINT










main "$@"
} 2>&1 | tee btk.log
