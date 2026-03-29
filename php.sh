##!/usr/bin/env bash
# curl -LO https://gist.githubusercontent.com/mannysoft/e4b54662b3aec5c0b1b88be52177ab68/raw/04dba433394c7a03d891f94c75b52975d2e7a621/install.sh
# chmod +x install.sh
# ./install.sh
# ppk to pem:
# puttygen key.ppk -O private-openssh -o key.pem

echo "--- Welcome User. This is very exciting. ---"

echo "--- Updating packages list ---"
sudo apt-get install software-properties-common
#https://colorfield.be/blog/fix-following-signatures-couldnt-be-verified-because-public-key-not-available-ubuntu-1604
sudo add-apt-repository ppa:ondrej/nginx
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

#echo "--- Installing text editor NANO ---"
#sudo apt-get install -y nano

#echo "--- Installing git ---"
#sudo apt-get install -y git-core

#echo "--- Installing MySQL ---"
#sudo apt-get update
#sudo apt-get install -y mysql-server
#sudo mysql_secure_installation
# https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-18-04


echo "--- Installing PHP-specific packages and Curl ---"
sudo apt install -y php7.4 php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-mysql php7.4-fpm php7.4-ldap php7.4-tidy php7.4-bcmath php7.4-mbstring php7.4-xml php7.4-curl php7.4-zip php7.4-gd php7.4-sqlite3 php7.4-redis --allow-unauthenticated

echo "--- Applying modifications to php7.4-fpm ---"
sudo sed -i '/cgi.fix_pathinfo=1/c cgi.fix_pathinfo=0' /etc/php/7.4/cli/php.ini
sudo sed -i '/max_execution_time = 30/c max_execution_time = 300' /etc/php/7.4/cli/php.ini
sudo sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 80M' /etc/php/7.4/cli/php.ini
sudo sed -i '/post_max_size = 8M/c post_max_size = 80M' /etc/php/7.4/cli/php.ini

sudo sed -i '/upload_max_filesize = 2M/c upload_max_filesize = 80M' /etc/php/7.4/fpm/php.ini
sudo sed -i '/post_max_size = 8M/c post_max_size = 80M' /etc/php/7.4/fpm/php.ini

echo "--- Check if no error in nginx ----"
sudo nginx -t

echo "--- Restart PHP-FPM if everything is ok ---"
sudo systemctl restart php7.4-fpm.service

echo "--- Enable Nginx and PHP-FPM on system boot ---"
sudo systemctl enable nginx.service
sudo systemctl enable php7.4-fpm.service

# Create folder
sudo mkdir -p /var/www/html
#sudo mkdir -p /var/www/html/public

echo "--- Configuring default Nginx site to support Laravel ---"
cat << 'EOF' | sudo tee /etc/nginx/sites-available/default
server {
        listen 8080 default_server;
        listen [::]:8080 default_server ipv6only=on;

        root /var/www/html;
        index index.php index.html index.htm;
        
        server_name _;

        location / {
                try_files $uri $uri/ /index.php?$query_string;
        }
        location ~ \.php$ {
                try_files $uri =404;
                fastcgi_split_path_info ^(.+\.php)(/.+)$;
                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
        }
}
EOF


echo "--- Restarting php7.4-fpm and Nginx ---"
sudo /etc/init.d/nginx restart
sudo /etc/init.d/php7.4-fpm restart

# Create Swap File (Optional)
# sudo fallocate -l 1G /swapfile
# sudo mkswap /swapfile
# sudo swapon /swapfile

echo "--- Fetching and installing Composer ---"
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# echo "--- Installing node.js ---"
sudo apt-get install -y nodejs --allow-unauthenticated
sudo apt-get install -y npm --allow-unauthenticated
#laravel-echo-server start
#nodejs-legacy


#sudo chown -R username /var/www/app
sudo chown -R www-data /var/www
 sudo chmod -R 777 /var/www/html
sudo chmod -R 777 /var/www/html/*

echo "--- Restarting php7.4-fpm and Nginx ---"
sudo /etc/init.d/nginx restart
sudo /etc/init.d/php7.4-fpm restart

#phpmyadmin
#sudo apt-get install -y --allow-unauthenticated phpmyadmin
 #sudo ln -s /usr/share/phpmyadmin /var/www/html


# Install SSL Certificate
# https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04
#sudo add-apt-repository ppa:certbot/certbot
#sudo apt-get update
#sudo apt-get install python-certbot-nginx
#sudo certbot --nginx -d host.ospro.pt -d www.ospro.pt

# Set up subdomain
#https://hackprogramming.com/how-to-setup-subdomain-or-host-multiple-domains-using-nginx-in-linux-server/

# Install MailHog for email testing
# https://mannyisles.com/install-mailhog-with-nginx-on-ubuntu-server/

# Install supervisor
#sudo apt-get install supervisor -y

# https://laravel.com/docs/7.x/queues#running-the-queue-worker

# MongoDB
# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
#sudo apt-get install php-mongodb
