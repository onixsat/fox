#!/bin/bash

# Interromper o script imediatamente se ocorrer algum erro
set -e

# Cores para o output do terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Configuração do Servidor Apache + PHP + SSL ===${NC}"

# 1. INPUT DO DOMÍNIO
read -p "$(echo -e ${YELLOW}"Introduza o Domínio [padrão: secure.ospro.pt]: "${NC})" INPUT_DOMAIN
DOMAIN=${INPUT_DOMAIN:-"secure.ospro.pt"}

# 2. INPUT DO IP
read -p "$(echo -e ${YELLOW}"Introduza o IP do Servidor [padrão: 51.158.97.92]: "${NC})" INPUT_IP
SERVER_IP=${INPUT_IP:-"51.158.97.92"}

# 3. INPUT DO EMAIL (Importante para avisos de expiração do SSL)
read -p "$(echo -e ${YELLOW}"Introduza o Email de Administração [padrão: admin@ospro.pt]: "${NC})" INPUT_EMAIL
ADMIN_EMAIL=${INPUT_EMAIL:-"admin@ospro.pt"}

echo -e "\n${GREEN}A iniciar a configuração para:${NC}"
echo -e "Domínio: ${BLUE}$DOMAIN${NC}"
echo -e "IP:      ${BLUE}$SERVER_IP${NC}"
echo -e "Email:   ${BLUE}$ADMIN_EMAIL${NC}\n"

# Confirmação antes de avançar
read -p "Deseja continuar? (s/n): " CONFIRM
if [[ $CONFIRM != "s" && $CONFIRM != "S" ]]; then
    echo -e "${YELLOW}Instalação cancelada pelo utilizador.${NC}"
    exit 0
fi

echo -e "\n${GREEN}[1/5] A atualizar os repositórios do sistema...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}[2/5] A instalar o Apache e o Certbot (para SSL Let's Encrypt)...${NC}"
sudo apt install apache2 apache2-utils certbot python3-certbot-apache -y

echo -e "${GREEN}[3/5] A instalar o PHP 8.3 e extensões comuns para produção...${NC}"
sudo apt install php libapache2-mod-php php-cli php-common php-curl php-gd php-mbstring php-xml php-zip php-mysql php-intl -y

echo -e "${GREEN}[4/5] A configurar o VirtualHost no Apache...${NC}"
sudo a2enmod rewrite
sudo a2enmod ssl

# Criar o ficheiro de configuração HTTP baseado nas variáveis introduzidas
sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot /var/www/html

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Desativar o site padrão e ativar o novo site customizado
sudo a2dissite 000-default.conf
sudo a2ensite $DOMAIN.conf
sudo systemctl reload apache2

echo -e "${GREEN}[5/5] A emitir e instalar o Certificado SSL Let's Encrypt válido...${NC}"
# Executa o certbot com as variáveis inseridas pelo utilizador
sudo certbot --apache -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect

# Criar página inicial limpa e segura
echo "<?php echo '<h1>Ambiente Seguro Configurado com Sucesso no domínio ' . \$_SERVER['SERVER_NAME'] . '</h1>'; ?>" | sudo tee /var/www/html/index.php > /dev/null

# Reiniciar o Apache para aplicar tudo
sudo systemctl restart apache2

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}Configuração concluída com sucesso!${NC}"
echo -e "Domínio configurado: ${YELLOW}https://$DOMAIN${NC}"
echo -e "IP do Servidor: ${YELLOW}$SERVER_IP${NC}"
echo -e "O SSL renova-se automaticamente."
echo -e "${GREEN}====================================================${NC}"
