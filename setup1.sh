#!/bin/bash

# Interromper o script imediatamente se ocorrer algum erro
set -e

# Variáveis específicas do ambiente
DOMAIN="secure.ospro.pt"
SERVER_IP="51.158.97.92"
ADMIN_EMAIL="admin@ospro.pt" # Altere para o seu email real para avisos de renovação

# Cores para o output do terminal
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}[1/5] A atualizar os repositórios do sistema...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}[2/5] A instalar o Apache e o Certbot (para SSL Let's Encrypt)...${NC}"
sudo apt install apache2 apache2-utils certbot python3-certbot-apache -y

echo -e "${GREEN}[3/5] A instalar o PHP 8.3 e extensões comuns para produção...${NC}"
sudo apt install php libapache2-mod-php php-cli php-common php-curl php-gd php-mbstring php-xml php-zip php-mysql php-intl -y

echo -e "${GREEN}[4/5] A configurar o VirtualHost no Apache...${NC}"
# Ativar módulos recomendados
sudo a2enmod rewrite
sudo a2enmod ssl

# Criar o ficheiro de configuração HTTP base para o seu domínio
sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot /var/www/html

    # Configuração de Logs dedicada para o domínio
    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined

    # Permitir override de .htaccess (importante para frameworks e CMS)
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Desativar o site padrão do Apache e ativar o seu novo domínio
sudo a2dissite 000-default.conf
sudo a2ensite $DOMAIN.conf
sudo systemctl reload apache2

echo -e "${GREEN}[5/5] A emitir e instalar o Certificado SSL Let's Encrypt válido...${NC}"
echo -e "${YELLOW}Aviso: A validação do Certbot vai comunicar com o DNS para verificar o domínio.${NC}"

# Executa o certbot, aceita os termos e configura o redirecionamento automático de HTTP para HTTPS
sudo certbot --apache -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect

# Criar um ficheiro seguro de teste PHP (esconde o phpinfo padrão por segurança)
echo "<?php echo '<h1>Ambiente Seguro Configurado com Sucesso no domínio ' . \$_SERVER['SERVER_NAME'] . '</h1>'; ?>" | sudo tee /var/www/html/index.php > /dev/null

# Reiniciar o serviço final para garantir que tudo está ativo
sudo systemctl restart apache2

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}Configuração concluída com sucesso!${NC}"
echo -e "Domínio configurado: ${YELLOW}https://$DOMAIN${NC}"
echo -e "IP do Servidor: ${YELLOW}$SERVER_IP${NC}"
echo -e "O SSL renova-se automaticamente através do cron/systemd do Certbot."
echo -e "${GREEN}====================================================${NC}"
