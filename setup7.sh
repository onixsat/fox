#!/bin/bash

if [ -e "class.sh" ]; then
    sudo rm -R class.sh
fi

wget https://raw.githubusercontent.com/onixsat/fox/refs/heads/main/class.sh
source class.sh

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
if [ -z "$var3" ]; then
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


function app1(){
	banner "Menu" "Nginx" "Editar"
	
	step "Ligar localhost:"
		try "ls"
	next
	
	esperar2 "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"
}


app1




 


