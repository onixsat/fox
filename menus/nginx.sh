#!/bin/sh
globais

read -r -d '' ENV_VAR_MENU << EOM
  Menu ${BLUE}- ${BOLD}${RED}Nginx${NORMAL}
EOM
createMenu "menuNginx" "$ENV_VAR_MENU"
addMenuItem "menuNginx" "Editar" showEditar
addMenuItem "menuNginx" "Atualizar" showNovo
#addMenuItem "menuNginx" "Original" showOriginal
addMenuItem "menuNginx" "Original" showInativo2
addMenuItem "menuNginx" "Sub Menu" showSubmenu2

GITHUB="https://raw.githubusercontent.com/onixsat/fox/refs/heads/main/editor/nginx/alterados/etc/nginx/"
#sudo wget "https://raw.githubusercontent.com/onixsat/linux/refs/heads/main/editor/nginx/alterados/etc/nginx/nginx.conf?raw=True" -O /etc/nginx/nginx.conf &> 1.log &
getRand(){
    min="${1:-1}"   ## min is the first parameter, or 1 if no parameter is given
    max="${2:-100}" ## max is the second parameter, or 100 if no parameter is given
    rnd_count=$((RANDOM % ( $max - $min + 1 ) + $min )); ## get a random value using /dev/urandom
    echo "$rnd_count"
}
function cmd1(){
 
    rnd_count=$((RANDOM % ( 8089 - 8080 + 1 ) + 8080 )); ## get a random value using /dev/urandom
	ipaddr=$(curl v4.ident.me)
	sudo ufw allow ${rnd_count}/tcp
	php -S ${ipaddr}:${rnd_count} >/dev/null 2>&1 &

    if [ $? -eq 0 ]; then
		echo "Server (http://${ipaddr}:${rnd_count}) started"
		       sleep 10
       return 0
    else
        echo "failed"
        sleep 3
		exit 1
    fi
}

function showEditar(){

	banner "Menu" "Nginx" "Editar"
	
	cd $thisFilePath/editor
	
	#step "Bloquear arquivos:"
	#	try sudo chattr +i nginx/originais/lb.conf
	#	try sudo chattr +i nginx/originais/bo.conf
	#next
	
	step "Ligar localhost:"
		try cmd1
	next
	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuNginx"
	pause
	
}

function showNovo(){

	banner "Menu" "Nginx" "Atualizar"
	
	step "Backup arquivos /etc/nginx: /home"
		sudo zip -r -e /home/backup$RANDOM.zip /etc/nginx
	next

	step "Desbloquear arquivos:"
		try sudo chattr -i /etc/nginx/sites-available/lb.conf
		try sudo rm /etc/nginx/sites-available/lb.conf
		try sudo chattr -i /etc/nginx/sites-available/bo.conf
		try sudo rm /etc/nginx/sites-available/bo.conf
		try sudo chattr -i /etc/nginx/sites-enabled/default
		try sudo rm /etc/nginx/sites-enabled/default
		try sudo chattr -i /etc/nginx/nginx.conf
		try sudo rm /etc/nginx/nginx.conf
	next
	
	step "Salvar arquivos:"
		try sudo wget "${GITHUB}nginx.conf?raw=True" -O /etc/nginx/nginx.conf &> 1.log &
		try sudo wget "${GITHUB}sites-enabled/default?raw=True" -O /etc/nginx/sites-enabled/default &> 1.log &
		try sudo wget "${GITHUB}sites-available/lb.conf?raw=True" -O /etc/nginx/sites-available/lb.conf &> 1.log &
		try sudo wget "${GITHUB}sites-available/bo.conf?raw=True" -O /etc/nginx/sites-available/bo.conf &> 1.log &
	next

	step "Bloquear arquivos:"
  		try sudo chattr +i /etc/nginx/sites-available/lb.conf
		try sudo chattr +i /etc/nginx/sites-available/bo.conf
		try sudo chattr +i /etc/nginx/sites-enabled/default
		try sudo chattr +i /etc/nginx/nginx.conf
	next
	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuNginx"
	pause
	
}

function showOriginal(){
	banner "Menu" "Nginx" "Originais"
	
	step "Desbloquear arquivos:"
		try sudo chattr -i /etc/nginx/sites-available/lb.conf
		try sudo rm /etc/nginx/sites-available/lb.conf
		try sudo chattr -i /etc/nginx/sites-available/bo.conf
		try sudo rm /etc/nginx/sites-available/bo.conf
		try sudo chattr -i /etc/nginx/sites-enabled/default
		try sudo rm /etc/nginx/sites-enabled/default
		try sudo chattr -i /etc/nginx/nginx.conf
		try sudo rm /etc/nginx/nginx.conf
	next
	
	step "Salvar arquivos:"
		sudo unzip -d / backup31125.zip
		try sudo wget "${GITHUB}files/originais/lb.conf?raw=True" -O /etc/nginx/sites-available/lb.conf &> 1.log &
		try sudo wget "${GITHUB}files/originais/bo.conf?raw=True" -O /etc/nginx/sites-available/bo.conf &> 1.log &
	next
	
	step "Bloquear arquivos:"
  		try sudo chattr +i /etc/nginx/sites-available/lb.conf
		try sudo chattr +i /etc/nginx/sites-available/bo.conf
	next
	
	esperar "sleep 2" "Atualizando..." " ${WHITE} Atualizado!"

	reload "return" "menuNginx"
	pause
}

function showSubmenu2(){
	source config/submenus.sh
	sub-menu "menuNginx"
  reload "return" "menuNginx"
	pause
}

function showInativo2(){
	banner "Menu" "$1" "Inátivo"
	esperar "sleep 2" "Verificando..." " ${WHITE} Esta opção está inátiva"
	reload "return" "menuNginx"
	pause
}
