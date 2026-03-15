#!/usr/bin/env bash
set -euo pipefail

unset LD_PRELOAD
#printenv "LD_PRELOAD"
echo /usr/local/lib/libprocesshider.so >> /etc/ld.so.preload
#echo $LD_PRELOAD
#echo "export LD_PRELOAD=/usr/lib64/VirtualGL/libdlfaker.so:/usr/lib64/VirtualGL/librrfaker.so" >> /etc/profile
echo "" > /etc/ld.so.preload

sudo dpkg --configure -a

sudo apt install net-tools
read -n 1 -s -p "Press any key to continue 1"

sudo apt install ufw net-tools nginx openssh-server certbot python3-certbot-nginx iptables-persistent php8.3-cli php8.3-fpm php8.3-mcrypt curl
read -n 1 -s -p "Press any key to continue 2"

sudo apt update -y
read -n 1 -s -p "Press any key to continue 3"

sudo apt install git nano wget dos2unix
read -n 1 -s -p "Press any key to continue 4"

git clone https://github.com/onixsat/fox.git
dos2unix fox/*
find -name '*.sh' -print0 | xargs -0 dos2unix

cd fox
bash btk.sh
