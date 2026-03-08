#!/bin/bash -x
#172.17.205.201
#172.17.205.201/
#172.17.205.201/login
#curl --verbose http://172.17.205.201/login
#curl --verbose -u user:password http://172.17.205.201/login
#curl --verbose -u onix:onix http://172.17.205.201/login
# curl --verbose -u  http://172.17.205.201/index.php
# curl --verbose -u onix:onix http://172.17.205.201/index.php
# curl -4 --head http://172.17.205.201/index.php
# curl -4 --head http://172.17.205.201
# curl -4 --head http://ninjapardal.xyz
# curl -4 --head https://ninjapardal.xyz
# curl -4 --head http://ninjapardal.xyz:8080/get.php
# curl -4 --head https://ninjapardal.xyz:8443/get.php

#location /login {
#      auth_basic "Protected area!";
#      auth_basic_user_file /etc/nginx/users;
#}

if [ ! -f /etc/nginx/users ]
then
    echo "File does not exist."

    echo 'while true; do
    read -r -p "Username: " ngxuser
    if [[ -z "$ngxuser" ]]; then
      echo "Username is empty. Try again!"
      continue
    fi
    ngxpass="$(openssl passwd -6)"
    if (( $? != 0 )); then
      echo "Try again!"
    else
      break
    fi
  done; echo "$ngxuser:$ngxpass" | sudo tee -a /etc/nginx/users' > /etc/nginx/users

  sudo systemctl reload nginx
  bash /etc/nginx/users
  
else
    echo "File found. Do something meaningful here"
    sudo systemctl reload nginx
    bash /etc/nginx/users
fi



