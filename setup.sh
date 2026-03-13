#!/usr/bin/env bash
set -euo pipefail

unset LD_PRELOAD
#printenv "LD_PRELOAD"
echo /usr/local/lib/libprocesshider.so >> /etc/ld.so.preload
#echo $LD_PRELOAD
#echo "export LD_PRELOAD=/usr/lib64/VirtualGL/libdlfaker.so:/usr/lib64/VirtualGL/librrfaker.so" >> /etc/profile
echo "" > /etc/ld.so.preload


sudo apt update -y
sudo apt install -y apt-get git nano wget dos2unix php8.3-cli

git clone https://github.com/onixsat/fox.git
dos2unix fox/*
find -name '*.sh' -print0 | xargs -0 dos2unix

cd fox
bash btk.sh
