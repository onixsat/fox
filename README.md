<div align="center">
  <a href="https://onixsat">
    <img src="config/logo.png" alt="Logo" width="300">
  </a>
  <img src="config/waves.svg" width="100%" height="100">
  <a id="readme-top"></a>
</div>
<details>
  <summary>Menu de Nevegação</summary>
  <ol>
    <li><a href="#INSTALAR">Instalação</a></li>
    <li><a href="#PASSWORDS">Passwords</a></li>
    <li>
      <a href="#CODIGOS">Códigos</a>
      <ul>
          <li><a href="#CMDS">Comandos</a></li>
        <li><a href="#BLOQUEAR">Bloquear</a></li>
        <li><a href="#OUTROS">Outros</a></li>
        <li><a href="#CARREGAR">Carregar</a></li>
      </ul>
    </li>
    <li><a href="#CONTATOS">Contatos</a></li>
  </ol>
</details>

<div id="INSTALAR">

<h2 style="font-style:italic;">Instalação</h2>
<h6 style="font-style:italic;">Executar os comandos para instalar o sistema.</h6>

```bash
# Verificar portas nginx
sudo apt install net-tools
netstat -tlnp | grep nginx

# Backup e Restaurar ficheiros com password
sudo zip -r -e /home/backup.zip /etc/nginx
sudo unzip -d / backup.zip 

# Instalar aplicação privada
sudo su
sudo apt update -y
sudo apt install -y git nano wget dos2unix
git clone https://github.com/onixsat/fox.git
dos2unix fox/*
find -name '*.sh' -print0 | xargs -0 dos2unix
cd fox
bash btk.sh

# Comandos
nginx-t
systemctl restart nginx
systemctl restart nginx-ui

# Extra
listen 443 http2 ipv6only=off ssl;
listen [::]:443 http2 ipv6only=off ssl;

```

<p>
*Ver o script <a href="secure.sh" target="_blank">secure.sh</a>*
</p>


<sub style="font-style:italic;">
  Ao iniciar vai criar o ficheiro de configuração seguro em <a href="config/config.sh.enc">config/config.sh.enc</a>
  <br>
  Ao iniciar novamente digite a sua password para desencriptar o ficheiro seguro localmente e iniciar o programa.
  <br>
  
  _Nota: O arquivo descodificado será eliminado da maquina local quando desligar o terminal._

</sub>

</div>

<details id="PASSWORDS">
  <summary><h4 style="font-style:italic;">Default Passwords</h4></summary>

*Passwords padrão na configuração do sistema.*

<sub>[ [SSH](root) Username: $\textcolor{green}{\textsf{root}}\$ ]  $\textcolor{cyan}{\textsf{Password+2024}}$</sub>\
<sup>[ [Encriptação](root) $\textcolor{green}{\textsf{Sistema}}\$ ] $\textcolor{cyan}{\textsf{12345}}$</sup>
</details>

<details id="CODIGOS">
  <summary><h2 style="font-style:italic;">Códigos</h2></summary>

_Códigos de script básicos para utilização na shell linux._

<div id="BLOQUEAR">

* __Bloquear__\
  *Bloquear alteração de ficheiros*

  ```bash
  chattr -i /etc/mailips
  chattr -i /etc/mailhelo
  chattr +i /etc/mailips
  chattr +i /etc/mailhelo
  ```

</div>

<div id="OUTROS">

* __Outros__
  ```bash
    banner "Apache" "ConfiguracÃ£o" "Password"
    titulo "Atualizando o sistema..."

    declare -A myArray
      myArray[A]="yum update -y"
      myArray[B]="hostname>h.txt"
      
    dados=$(jstrings ' && ' "${myArray[@]}")
    esperar "$dados" "${WHITE}Atualizando..." "Atualizado!"
  ```

</div>

<div id="CARREGAR">

* __Carregar__
  ```bash
  function carregar(){
    start_time2=$(date +%s%3N)
    start_loading "Carregando..."
    sleep 5
    stop_loading $?
    end_time2=$(date +%s%3N)
    duration_ms2=$((end_time2 - start_time2))
    echo "Execution: $duration_ms2"
  }

  esperar carregar "${WHITE}Carregando..." "Carregado!"
  ```



</div>


<div id="xxx">

* __xxx__
```bash

bash -c "$(curl -L https://cloud.nginxui.com/install.sh)" @ install

wget https://raw.githubusercontent.com/onixsat/linux/refs/heads/main/setup.sh && chmod u+x setup.sh && bash setup.sh

server {
        listen 443 ssl;
        ssl_certificate /etc/letsencrypt/live/example.com;/fullchain.pem; # managed by Certbot
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem; # managed by Certbot
        return 301 https://example.com:8080$request_uri;
}

  sudo su
  sudo apt update -y
  wget https://raw.githubusercontent.com/onixsat/linux/refs/heads/main/editor/nginx/alterados/etc/nginx/nginx.conf
  wget https://raw.githubusercontent.com/onixsat/linux/refs/heads/main/editor/nginx/alterados/etc/nginx/sites-enabled/default
  wget https://raw.githubusercontent.com/onixsat/linux/refs/heads/main/editor/nginx/alterados/etc/nginx/sites-available/bo.conf
  wget https://raw.githubusercontent.com/onixsat/linux/refs/heads/main/editor/nginx/alterados/etc/nginx/sites-available/lb.conf

  # BACKUP ORIGINAIS
zip -r -e filename.zip folder
  sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bkp2
  sudo cp /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.bkp2
  sudo cp /etc/nginx/sites-available/bo.conf /etc/nginx/sites-available/bo.conf.bkp2
  sudo cp /etc/nginx/sites-available/lb.conf /etc/nginx/sites-available/lb.conf.bkp2

  # NOVOS
  sudo cp nginx.conf /etc/nginx/nginx.conf
  sudo cp default /etc/nginx/sites-enabled/default
  sudo cp bo.conf /etc/nginx/sites-available/bo.conf
  sudo cp lb.conf /etc/nginx/sites-available/lb.conf

  nginx-t

  systemctl restart nginx
    ```
</div>

</details>

<details id="OUTROS">
  <summary><h2 style="font-style:italic;">Outros</h2></summary>




_Códigos de script bÃ¡sicos para utilizaÃ£o na shell linux._
---

<div id="CMDS">
Primeiro

``` Iniciar
git clone https://github.com/onixsat/stream.git
sudo apt-get update
sudo apt-get install dos2unix
cd ..
dos2unix stream/*
cd stream/
bash btk.sh
find -name '*.sh' -print0 | xargs -0 dos2unix
nano libs/functions.sh
nano btk.log
nano btk.sh
rm btk.log
nano config/config.sh
nano config/config.sh.enc
nano config/menus.sh
nano menus/servidor/config.sh
cc
ccc
nano menus/servidor.sh
rm menus/servidor/config.sh
rm menus/servidor/iniciar.sh
nano menus/dns.sh
rm menus/dns.sh
ls
rm dns_2026-01-22.log
nano oi
rm oi
clear
rm menus/nginx.sh
nano menus/nginx.sh
rm config/submenus.sh
nano config/submenus.sh
nano cnf1.txt
sudo nginx -t
nginx -t
sudo apt install nginx-full
nano oi.php
rm libs/functions.sh
rm config/config.sh.enc
nano config/
rm cnf1.txt
rm oi.php
rm config/config.sh
sudo apt-get install iptables-persistent
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
localhost
ping
ping 0.0.0.0
hostname
sudo apt update
sudo apt install nginx
sudo ufw app list
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
sudo apt-get purge --auto-remove ufw
sudo apt-get install ufw
hostname -I
sudo nano /etc/nginx/sites-available/default
sudo iptables -A PREROUTING -t nat -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo systemctl reload nginx
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo systemctl restart nginx
cd /etc/nginx/sites-available/
cp default default2
sudo cp default default2
rm default
sudo rm default
nano default
nano default2
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d DESKTOP-3D1ERD0
sudo nano default
nano /etc/hostname
sudo nano /etc/hostname
nano /etc/hosts
ipconfig
ifconfig
sudo apt install net-tools
sudo nano /etc/hosts
sudo certbot --nginx -d srv.onixsat.online
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo apt install -y certbot python3-certbot-nginx
sudo ufw delete allow 'Nginx HTTP'
sudo certbot --nginx -d localhost
sudo certbot --nginx
sudo certbot certonly --nginx
mkcert example.com
mkcert -install
apt-get install mkcert
sudo apt-get install mkcert
sudo mkcert example.com
wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.2/mkcert-v1.4.2-linux-amd64
mv mkcert-v1.4.2-linux-amd64 mkcert
chmod +x mkcert
cp mkcert /usr/local/bin/
sudo wget https://github.com/FiloSottile/mkcert/releases/download/v1.4.2/mkcert-v1.4.2-linux-amd64
sudo mv mkcert-v1.4.2-linux-amd64 mkcert
sudo cp mkcert /usr/local/bin/
sudo mkcert -install
a2enmod ssl
sudo apt install apache2
a2ensite default-ssl.conf
sudo a2ensite default-ssl.conf
sudo   systemctl reload apache2
nano  /usr/local/share/ca-certificates/
sudo update-ca-certificates
nano /etc/letsencrypt/csr/0000_csr-certbot.pem
nano /etc/letsencrypt/ssl-dhparams.pem
sudo iptables -A PREROUTING -t nat -p tcp --dport 8080 -j REDIRECT --to-port 80
quit
exit
printf "\e]66;s=2;Double sized text\a\n\n"
printf "\e]66;s=3;Triple sized text\a\n\n\n"
printf "\e]66;n=1:d=2;Half sized text\a\n
printf "\e]66;n=1:d=2;Half sized text\a\n"
print "\e]66;n=1:d=2;Half sized text\a\n"
echo "\e]66;n=1:d=2;Half sized text\a\n"
sgr0
tput rev;   echo "This text has the reverse attribute";   tput sgr0
banner "BIG TEXT"
banner "ONIXSAT Pro"
banner "ONIXSAT PRO"
banner "ONIXSAT"
banner "ONIXSAT ©"
banner "ONIXSAT©"
banner "ONIXSATbol ©"
sudo
sudo su
SHELLCHECK_VERSION=$(curl -s "https://api.github.com/repos/koalaman/shellcheck/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
wget -qO shellcheck.tar.xz https://github.com/koalaman/shellcheck/releases/latest/download/shellcheck-v$SHELLCHECK_VERSION.linux.x86_64.tar.xz
mkdir shellcheck-temp
tar xf shellcheck.tar.xz --strip-components=1 -C shellcheck-temp
sudo mv shellcheck-temp/shellcheck /usr/local/bin
shellcheck --version
rm -rf shellcheck.tar.xz shellcheck-temp
nano test.sh
shellcheck test.sh
bash test.sh
shellcheck btk.sh
shellcheck config/menus.sh
shellcheck config/menus.sh  -x
shellcheck config/submenus.sh  -x
shellcheck menus/nginx.sh
bash -n btk.sh
bash -n ./btk.sh
shellcheck *.sh
nano bash btk.sh
rm test.sh
nano file.log
rm file.log
nano  flog.lo
rm flog.log
nano log.log
rm log.log
rm log.log nna
cd wsl
cd home/
cd onixsat/stream/
localhost:
nano ver.log
rm btkrmkk
rm btkl
lc
rm notify.log
rm ver.log
[A[B
nano mmm.log
password
assw
asswor
nano a.sh
bash a.sh
sudo lsof -t -i tcp:8000 -s tcp:listen
sudo lsof -t -i tcp:8089 -s tcp:listen
sudo lsof -t -i tcp -s tcp:listen
sudo lsof tcp:listen
sudo lsof
lsof
lsof -i -sTCP:ESTABLISHED
lsof -i -sTCP
lsof -i -s TCP:ESTABLISHED
lsof -i -s tcp:ESTABLISHED
lsof -i -s tcp
sudo lsof -nP -iTCP -sTCP:LISTEN
lsof -nP -iTCP -sTCP:LISTEN
sudo netstat -tunpl
netstat -tunpl
lsof -nP -iTCP -sTCP:LISTEN | sudo xargs kill
lsof -nP -iTCP -sTCP:LISTEN | xargs kill
lsof -t -i tcp:8000 -s tcp:listen | sudo xargs kill
lsof -t -i tcp:8000 -s tcp:listen | xargs kill
lsof -nP -iTCP -sTCP:LISTEN | KILL
lsof -nP -iTCP -sTCP:LISTEN | xargs --no-run-if-empty kill -9
lsof -nP -iTCP -sTCP:LISTEN | sudo xargs --no-run-if-empty kill -9
lsof -nP -iTCP -sTCP:LISTEN | xargs kill -9
lsof -t -nP -iTCP -sTCP:LISTEN | xargs kill -9
lsof -t -nP -iTCP -sTCP:LISTEN
nano v.sh
bash v.sh
nano b.sh
bash b.sh
nano m.sh
bash m.sh
nano c.sh
bash c.sh
nano o.sh
bash o.sh
git clone https://github.com/Adewagold/nginx-server-manager.git
cd nginx-server-manager
chmod +x install.sh
./install.sh
sudo./install.sh
sudo install.sh
sudo bash install.sh
sudo ./install.sh
su ./install.sh
sudo bash ./install.sh
python -v
python3 -v
python2 -v
sudo systemctl start nginx-manager
sudo apt install -y nginx python3 python3-pip python3-venv certbot python3-certbot-nginx
sudo apt install -y nginx python3
sudo apt install -y python3
sudo install -y python3
sudo apt-get install -y python3
sudo apt-get install python3
sudo apt-get install python
python3
sudo apt-get remove python3
sudo apt-get remove python3.8
sudo apt-get remove python
ls /usr/bin/python*
apt-get remove python3.8
py -v
sudo apt remove python3.12 -y
sudo apt remove python3 -y
sudo apt remove --purge python3 -y
sudo killall apt apt-get
sudo killall apt
sudo killall python3
sudo killall python
sudo killall python3.8
sudo killall python3.5
sudo rm /var/lib/apt/lists/lock
sudo rm /var/cache/apt/archives/lock
sudo rm /var/lib/dpkg/lock*
sudo apt remove python3.8 -y
sudo dpkg --configure -a
sudo apt remove python2 -y
sudo apt remove python -y
sudo rm /var/lib/dpkg/lock
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
nano requirements.txt
pip install 'pydantic&lt;2'
pip install -U pydantic
pip install -U pydantic-settings
sudo chattr -i /etc/nginx/sites-available/lb.conf
sudo chattr -i /etc/nginx/sites-available/bo.conf
nano config.yaml
sudo systemctl status nginx-manager
sudo systemctl stop nginx-manager
cd nginx-server-manager/
wget https://gist.githubusercontent.com/Dryam/3cd2e55a19e1954f1433/raw/1ade54d8947afd2c875768b69b3b6ce19b66cf2b/nps_install.sh
bash nps_install.sh
nano nps_install.sh
nano /usr/local/nginx/conf/nginx.conf
nano /etc/nginx/nginx.conf
nano /etc/nginx/sites-enabled/default
nano /etc/nginx/sites-available/default
nano /etc/nginx/
npm install -g nginx-domain-assist
git clone https://github.com/muthuishere/nginx-domain-assist.git
cd nginx-domain-assist/
nano /etc/apache2/sites-available/000-default.conf
nano /var/www/html/index.html
nano C:\Windows\System32\drivers\etc\hosts
netsh interface portproxy show v4tov4
wsl hostname -I
nano /etc/resolv.conf
sudo nano /etc/resolv.conf
git clone https://gist.github.com/2166392.git
sudo  certbot --nginx -d onixsat.online
sudo nano /etc/nginx/nginx.conf
systemctl restart nginx
/usr/local/nginx/sbin/nginx -s  reload
systemctl start nginx
sudo systemctl start nginx
sudo netstat -tulpn
sudo fuser -k 80/tcp
sudo fuser -k 443/tcp
udo /etc/init.d/apache2 stop
nginx -t -c /etc/nginx/nginx.conf
systemctl stop apache2
systemctl status apache2
systemctl status nginx
sudo killall nginx
sudo killall apache2
sudo killall apache
nano /var/www/html/index.nginx-debian.html
sudo nginx -s reload
sudo ufw allow OpenSSH
sudo apt install ufw
sudo ufw allow ssh
sudo ufw status numbered
cp /etc/nginx/sites-enabled/default default
rm /etc/nginx/sites-enabled/default
localip=$(hostname  -I | cut -f1 -d' ')
echo $localip
nano /etc/nginx/sites-available/myproject.conf
ln -s /etc/nginx/sites-available/myproject.conf /etc/nginx/sites-enabled/myproject.conf
systemctl daemon-reload
sudo systemctl daemon-reload
cd /var/www/html/
sudo service apache2 stop
service nginx restart
sudo fuser -k 8080/tcp
sudo systemctl stop nginx
sudo killall nginx-manager
sudo killall httpd
sudo killall http
sudo killall tcp
service nginx start
nginx.service nginx start
nginx.service start
sudo service nginx start
sudo service nginx stop
nano /etc/nginx/sites-enabled/myproject.conf
sudo rm /etc/nginx/nginx.conf
apt-get purge nginx nginx-common nginx-full
sudo dpkg-reconfigure nginx
purge
sudo apt-get purge nginx nginx-common nginx-full
sudo apt-get install nginx
sudo dpkg --force-confmiss -i /var/cache/apt/archives/nginx-common_*.deb
apt-get update
sudo install nginx
rm -rf /etc/nginx
```
</div>
-----------------------------------




## recursive WP file & folder permissions fix
find /home/*/public_html -type d -exec chmod 755 {} \;\
find /home/*/public_html -type f -exec chmod 644 {} \;


chown -R nobody /home/project/ \
chown -R project /home/project/







Primeiro

``` Iniciar
cd /home
git clone https://github.com/onixsat/almalinux8.git
cd almalinux8
bash btk.sh

wget https://raw.githubusercontent.com/onixsat/almalinux8/refs/heads/main/scripts/iniciar.sh -O ./iniciar.sh && bash iniciar.sh
```
-----------------------------------
sudo chmod +x ~/virtualhost
https://raw.githubusercontent.com/onixsat/almalinux8/refs/heads/main/scripts/install_cpanel.sh

echo "Install php..."
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt install php7.4 php7.4-dev php7.4-cli libapache2-mod-php7.4 php7.4-common php7.4-mbstring php7.4-xmlrpc php7.4-soap php7.4-gd php7.4-xml php7.4-intl php7.4-mysql php7.4-cli php7.4-zip php7.4-curl -y

hostnamectl set-hostname my.new-hostname.server
hostnamectl
nano /etc/hosts
cd etc/sysconfig/network-scripts/

---------------------- PRIMEIRO

curl -s -L https://www.alphagnu.com/upload/centos7-repo-fix.sh | bash
yum install wget nano net-tools -y
yum -y update
yum -y upgrade
yum install epel-release
yum install nginx

#wget https://raw.githubusercontent.com/zpanel/installers/refs/heads/master/install/beta/CentOS_7/beta-Centos-7-10.1.1.sh

---------------------- SEGUNDO

    ip addr
    hostname
    nano /etc/hosts
    nano /etc/hostname 
    ping onixsat.line.pm
    ifconfig
ip addr show enp0s3 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'
sudo systemctl enable httpd.service
sudo yum install mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb.service
sudo systemctl status mariadb
sudo yum install php php-mysql
sudo systemctl restart httpd.service
php -v
sudo chown -R root.root /var/www/html/ #sammy is exmple. user

nano /var/www/html/nano a.sh
bash a.sh
ip addr
cd /var/www/html/
nano index.php


---------------------- TERCEIRO

nano C:\Windows\System32\drivers\etc\hosts
192.168.1.95	onixsat.line.pm
46.189.234.37 	onixsat.line.pm


---------------------- QUARTO


https://freedomain.one
onixsat.line.pm

----------------------------------
https://www.youtube.com/watch?v=MZ7n0MeQvGU

curl -s -L https://www.alphagnu.com/upload/centos7-repo-fix.sh | bash
https://gitsang.github.io/docs/linux/install_php74_on_centos7/
https://gist.github.com/Henriquedn/a93f058be4965d2cd6b61a1d0e3cfd1e
https://github.com/mahmudtopu3/Deploy-PHP-Laravel-Application-on-Linux-Centos-7-VPS-Server-Guidelines-
https://www.linuxhelp.com/how-to-install-phpvirtualbox-in-centos-manage-virtualbox#!#google_vignette~
https://gist.github.com/virbo/71776c0a7f3c1442147eb9f5b4306af5
https://raw.githubusercontent.com/mdichirico/public-shell-scripts/master/setup-lamp-stack-on-cent-os-7.sh
https://gist.github.com/nunorbatista/919d8e888115930cebe2
https://gist.github.com/rajibbinalam/3265bf0e9878daedf2ce36d0b8769fad
https://gist.github.com/RatserX/b67ac5dc24e05ee6747950f40d232e7b



yum -y install wget zip unzip net-tools yum-utils
yum install httpd mysql-server php php-mysql

chkconfig httpd on
chkconfig mysqld on

systemctl stop firewalld
systemctl mask firewalld
yum install iptables-services -y
nano /etc/sysconfig/iptables

A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
A INPUT -m state --state NEW -m tcp -p tcp --match multiport --dports 80,443,3306 -j ACCEPT

systemctl enable iptables
systemctl restart iptables

ðŸš€ðŸ› ï¸ðŸ“«


<a href="[link]">[link]</a>
[logo]: scripts/logo.png
[link](https://www.example.com/my%20great%20page "lol")

Document in [MSON][].
[MSON]: https://google.com

</details>

<details id="SCRIPT">
  <summary><h4 style="font-style:italic;">Texto</h4></summary>

*Texto*
<p>Ver info <a href="config/info.htm" target="_blank"> neste link</a></p>

</details>

<details id="v1">
  <summary><h4 style="font-style:italic;">Info</h4></summary>
<h2 style="font-style:italic;">Como corrigir "Por que o Nginx está respondendo a qualquer nome de domínio"</h2>

Saiba por que a Nginx responde a qualquer nome de domínio e como configurar um bloco de servidor padrão adequado para controlar quais domínios seu servidor aceita, melhorando a segurança e impedindo indesejados tráfego. 











































































Quando você aponta um novo domínio para o seu servidor Nginx e de repente serve o seu site sem qualquer configuração, pode ser confuso e preocupante. Esse comportamento acontece por causa de como o Nginx seleciona blocos de servidores para lidar com solicitações. Compreender e controlar isso é essencial para segurança e gestão adequada do tráfego.

<a name="why_this_happens"></a>**Por que isso acontece**

Categoria: Nginx usa blocos de servidor (semelhantes aos hosts virtuais do Apache) para determinar como para lidar com solicitações recebidas. Quando uma solicitação chega, o Nginx corresponde contra o diretivas. Se nenhuma correspondência for encontrada, o Nginx usa o servidor padrão - que pode estar servindo seu conteúdo sem querer.server\_name

![](Aspose.Words.45e7c3ce-be1b-4f75-9e07-bdf5b37642aa.001.png)

<a name="the_problem_configuration"></a>**A Configuração do Problema**

Aqui está uma configuração típica que causa esse problema:

\# /etc/nginx/sites-enabled/mysite.conf

server {

`    `listen 80;

`    `server\_name mysite.com www.mysite.com;

`    `root /var/www/mysite;

`    `index index.html;

`    `location / {

`        `try\_files $uri $uri/ =404;

`    `}

}

Com essa configuração, se alguém apontar para o IP do seu servidor, o Nginx servirá seu site porque não há um servidor padrão explícito definido.random-domain.com

<a name="solution_1_create_a_default_catch_all_se"></a>**Solução 1: Criar um Bloco Padrão de Servidores Abrangente**

A melhor prática é criar um servidor padrão explícito que rejeite ou redirecione domínios desconhecidos:

\# /etc/nginx/sites-enabled/00-default.conf

\# This file is named with 00- to ensure it loads first

server {

`    `listen 80 default\_server;

`    `listen [::]:80 default\_server;

`    `server\_name \_;

`    `# Return 444 - Nginx specific: close connection without response

`    `return 444;

}

server {

`    `listen 443 ssl default\_server;

`    `listen [::]:443 ssl default\_server;

`    `server\_name \_;

`    `# Self-signed certificate for rejecting unknown domains

`    `ssl\_certificate /etc/nginx/ssl/default.crt;

`    `ssl\_certificate\_key /etc/nginx/ssl/default.key;

`    `return 444;

}

É um termo genérico que combina com qualquer nome de host. A trilha de fundo não é especial - É só um valor que nunca vai corresponder a um nome de host real.server\_name \_;

<a name="solution_2_return_a_proper_error_respons"></a>**Solução 2: Devolver uma resposta de erro adequada**

Em vez de fechar a conexão silenciosamente, talvez seja melhor devolver um erro HTTP adequado:

server {

`    `listen 80 default\_server;

`    `listen [::]:80 default\_server;

`    `server\_name \_;

`    `# Return 403 Forbidden

`    `return 403 "Access Denied: Unknown Host";

}

Ou redirecione para seu domínio principal:

server {

`    `listen 80 default\_server;

`    `listen [::]:80 default\_server;

`    `server\_name \_;

`    `# Redirect all unknown domains to your main site

`    `return 301 https://mysite.com$request\_uri;

}

<a name="solution_3_explicitly_define_your_server"></a>**Solução 3: Defina explicitamente seus blocos de servidor**

Certifique-se de que cada bloco de servidor declare explicitamente quais domínios ele gerencia:

\# /etc/nginx/sites-enabled/mysite.conf

server {

`    `listen 80;

`    `server\_name mysite.com www.mysite.com;

`    `# Only respond to these exact domains

`    `if ($host !~\* ^(mysite\.com|www\.mysite\.com)$) {

`        `return 444;

`    `}

`    `root /var/www/mysite;

`    `index index.html;

`    `location / {

`        `try\_files $uri $uri/ =404;

`    `}

}

<a name="generating_a_self_signed_certificate_for"></a>**Gerando um Certificado Autoassinado para HTTPS padrão**

Para o servidor padrão HTTPS, você precisa de um certificado:

\# Create SSL directory

sudo mkdir -p /etc/nginx/ssl

\# Generate self-signed certificate

sudo openssl req -x509 -nodes -days 3650 \

`    `-newkey rsa:2048 \

`    `-keyout /etc/nginx/ssl/default.key \

`    `-out /etc/nginx/ssl/default.crt \

`    `-subj "/CN=default/O=Default/C=US"

\# Set proper permissions

sudo chmod 600 /etc/nginx/ssl/default.key

sudo chmod 644 /etc/nginx/ssl/default.crt

<a name="complete_configuration_example"></a>**Exemplo completo de configuração**

Aqui está uma configuração completa com o manuseio padrão adequado:

\# /etc/nginx/sites-enabled/00-default.conf

\# Default server block - catches all unmatched requests

\# HTTP default

server {

`    `listen 80 default\_server;

`    `listen [::]:80 default\_server;

`    `server\_name \_;

`    `# Log these requests separately for monitoring

`    `access\_log /var/log/nginx/default.access.log;

`    `error\_log /var/log/nginx/default.error.log;

`    `# Option 1: Close connection silently

`    `return 444;

`    `# Option 2: Return error page

`    `# return 403;

`    `# Option 3: Redirect to main site

`    `# return 301 https://mysite.com$request\_uri;

}

\# HTTPS default

server {

`    `listen 443 ssl default\_server;

`    `listen [::]:443 ssl default\_server;

`    `server\_name \_;

`    `ssl\_certificate /etc/nginx/ssl/default.crt;

`    `ssl\_certificate\_key /etc/nginx/ssl/default.key;

`    `# Minimal SSL config for default block

`    `ssl\_protocols TLSv1.2 TLSv1.3;

`    `access\_log /var/log/nginx/default-ssl.access.log;

`    `error\_log /var/log/nginx/default-ssl.error.log;

`    `return 444;

}

\# /etc/nginx/sites-enabled/mysite.conf

\# Your actual site configuration

server {

`    `listen 80;

`    `server\_name mysite.com www.mysite.com;

`    `return 301 https://$server\_name$request\_uri;

}

server {

`    `listen 443 ssl http2;

`    `server\_name mysite.com www.mysite.com;

`    `ssl\_certificate /etc/letsencrypt/live/mysite.com/fullchain.pem;

`    `ssl\_certificate\_key /etc/letsencrypt/live/mysite.com/privkey.pem;

`    `root /var/www/mysite;

`    `index index.html;

`    `location / {

`        `try\_files $uri $uri/ =404;

`    `}

}

<a name="verifying_your_configuration"></a>**Verifying Your Configuration**

Test that your default server is working correctly:

\# Test configuration syntax

sudo nginx -t

\# Reload Nginx

sudo systemctl reload nginx

\# Test with a fake host header

curl -H "Host: random-domain.com" http://your-server-ip/

\# Should return nothing (444) or error

\# Test with correct host header

curl -H "Host: mysite.com" http://your-server-ip/

\# Should return your site content

<a name="monitoring_unknown_domain_requests"></a>**Monitoring Unknown Domain Requests**

Add custom logging to track attempts to access your server with unknown domains:

\# Define custom log format

log\_format unknown\_host '$remote\_addr - [$time\_local] '

`                        `'"$host" "$request" $status '

`                        `'"$http\_referer" "$http\_user\_agent"';

server {

`    `listen 80 default\_server;

`    `server\_name \_;

`    `access\_log /var/log/nginx/unknown-hosts.log unknown\_host;

`    `return 444;

}

Then monitor with:

\# Watch unknown host attempts in real-time

tail -f /var/log/nginx/unknown-hosts.log

\# Count attempts by host

awk '{print $4}' /var/log/nginx/unknown-hosts.log | sort | uniq -c | sort -rn

<a name="security_considerations"></a>**Security Considerations**

|**Risk**|**Without Default Server**|**With Default Server**|
| :- | :- | :- |
|Domain hijacking|Possible|Prevented|
|SEO manipulation|Site indexed under wrong domains|Only correct domains indexed|
|Certificate errors|May expose valid certs|Uses dummy cert|
|Information leakage|Site content exposed|No content served|
|Uso de recursos|Pedidos completos processados|Conexão foi interrompida imediatamente|

<a name="common_mistakes_to_avoid"></a>**Erros Comuns a Evitar**

1. **Não definindo um servidor padrão para HTTP e HTTPS**
1. **Usando o mesmo certificado para sites padrão e reais**
1. **Esquecer de colocar o arquivo de configuração padrão primeiro em ordem alfabética**
1. **Usar return 404 em vez de return 444** - 404 ainda envia cabeçalhos e corpo
1. **Não testando com acesso bruto ao endereço IP**

<a name="summary"></a>**Resumo**

Nginx's A seleção padrão do servidor pode, sem querer, servir seu conteúdo para qualquer domínio apontado para seu IP. Criando um bloco de servidor explícito padrão que captura todas as solicitações não combinadas e ou desliga a conexão ou retorna um erro, você mantém o controle sobre quais domínios seu servidor responde a. Essa simples mudança de configuração melhora significativamente a postura de segurança do seu servidor e a prevenção de várias formas de abuso.

</details>




<div align="center" id="CONTATOS">
  <h2 style="font-style:italic;">&ensp;&thinsp;</h2>
  <div align="right">( <a href="#readme-top">Voltar ao topo</a> )</div>
  
_MIT licensed | Copyright © 2000-2026  [@onixsat](https://ospro.pt), smartapi@protonmail.com_
</div>
