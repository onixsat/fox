#!/bin/bash

# Interromper o script imediatamente se ocorrer algum erro inesperado
set -e

# Cores para o output do terminal
GREEN='\033;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Configuração Isolada Avançada (Apache/Nginx) + PHP + SSL + UFW ===${NC}"

# DETEÇÃO DO SERVIDOR WEB INSTALADO
WEB_SERVER=""
if command -v apache2 >/dev/null 2>&1; then
    WEB_SERVER="apache"
elif command -v nginx >/dev/null 2>&1; then
    WEB_SERVER="nginx"
else
    echo -e "${RED}Erro: Não foi detetado o Apache nem o Nginx instalado neste sistema.${NC}"
    echo -e "${YELLOW}Por favor, instale um dos servidores web antes de rodar este script.${NC}"
    exit 1
fi

echo -e "Servidor Web detetado: ${GREEN}${WEB_SERVER^^}${NC}\n"

# 1. INPUT DO DOMÍNIO
read -p "$(echo -e ${YELLOW}"Introduza o Domínio [padrão: secure.ospro.pt]: "${NC})" INPUT_DOMAIN
DOMAIN=${INPUT_DOMAIN:-"secure.ospro.pt"}

# Configuração do Diretório Dedicado
WEB_ROOT="/var/www/$DOMAIN"

# 2. INPUT DA PORTA COM VALIDAÇÃO DE CONFLITOS ATIVOS
while true; do
    read -p "$(echo -e ${YELLOW}"Introduza a Porta pretendida [padrão: 8123]: "${NC})" INPUT_PORT
    PORT=${INPUT_PORT:-"8123"}

    # Verifica se existe algum processo a escutar na porta TCP escolhida
    PORT_CHECK=$(sudo ss -tlnp | grep -E "[: ]${PORT} " || true)

    if [ -n "$PORT_CHECK" ]; then
        PROCESS_NAME=$(echo "$PORT_CHECK" | awk '{print $NF}' | cut -d'"' -f2 | head -n 1)
        echo -e "${RED}Erro: A porta $PORT já está ocupada pelo processo: [${PROCESS_NAME}].${NC}"
        echo -e "${YELLOW}Por favor, escolha uma porta diferente para não derrubar serviços ativos.${NC}\n"
    else
        echo -e "${GREEN}Sucesso: A porta $PORT está livre e segura para uso!${NC}"
        break
    fi
done

# 3. INPUT DO IP
read -p "$(echo -e ${YELLOW}"Introduza o IP do Servidor [padrão: 51.158.97.92]: "${NC})" INPUT_IP
SERVER_IP=${INPUT_IP:-"51.158.97.92"}

# 4. INPUT DO EMAIL (Importante para avisos de expiração do SSL)
read -p "$(echo -e ${YELLOW}"Introduza o Email de Administração [padrão: admin@ospro.pt]: "${NC})" INPUT_EMAIL
ADMIN_EMAIL=${INPUT_EMAIL:-"admin@ospro.pt"}

echo -e "\n${GREEN}A iniciar a configuração isolada avançada para:${NC}"
echo -e "Servidor:       ${BLUE}${WEB_SERVER^^}${NC}"
echo -e "Domínio:        ${BLUE}$DOMAIN${NC}"
echo -e "Diretório Raiz: ${BLUE}$WEB_ROOT${NC}"
echo -e "Porta:          ${BLUE}$PORT${NC}"
echo -e "IP:             ${BLUE}$SERVER_IP${NC}"
echo -e "Email:          ${BLUE}$ADMIN_EMAIL${NC}\n"

# Confirmação antes de avançar
read -p "Deseja continuar? (s/n): " CONFIRM
if [[ $CONFIRM != "s" && $CONFIRM != "S" ]]; then
    echo -e "${YELLOW}Instalação cancelada pelo utilizador.${NC}"
    exit 0
fi

echo -e "\n${GREEN}[1/6] A atualizar os repositórios do sistema...${NC}"
sudo apt update && sudo apt upgrade -y

echo -e "${GREEN}[2/6] A garantir que o Certbot está instalado...${NC}"
if [ "$WEB_SERVER" == "apache" ]; then
    sudo apt install certbot python3-certbot-apache -y
else
    sudo apt install certbot python3-certbot-nginx -y
fi

echo -e "${GREEN}[3/6] A instalar o PHP 8.3 e extensões comuns...${NC}"
sudo apt install php php-cli php-common php-curl php-gd php-mbstring php-xml php-zip php-mysql php-intl -y
if [ "$WEB_SERVER" == "apache" ]; then
    sudo apt install libapache2-mod-php -y
else
    sudo apt install php-fpm -y
fi

echo -e "${GREEN}[4/6] A criar e isolar o diretório exclusivo...${NC}"
sudo mkdir -p "$WEB_ROOT"
# Ajustar permissões para que o utilizador atual e o servidor web consigam gerir os ficheiros
sudo chown -R $USER:www-data "$WEB_ROOT"
sudo chmod -R 755 "$WEB_ROOT"

# Criar página inicial limpa e identificada no novo diretório exclusivo
echo "<?php echo '<h1>Ambiente 100% Isolado e Seguro Configurado com Sucesso no ' . \$_SERVER['SERVER_SOFTWARE'] . '</h1><p>Diretório: <strong>'$WEB_ROOT'</strong> na porta <strong>' . \$_SERVER['SERVER_PORT'] . '</strong></p>'; ?>" | sudo tee "$WEB_ROOT/index.php" > /dev/null

echo -e "${GREEN}[5/6] A aplicar configuração do host virtual para a porta $PORT...${NC}"

if [ "$WEB_SERVER" == "apache" ]; then
    sudo a2enmod rewrite ssl

    # Garante que o Apache escuta na porta nova, mantendo os restantes "Listen" intactos
    if ! grep -q "Listen $PORT" /etc/apache2/ports.conf; then
        echo "Listen $PORT" | sudo tee -a /etc/apache2/ports.conf > /dev/null
    fi

    # Criar VirtualHost Apache apontando para a pasta exclusiva
    sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null <<EOF
<VirtualHost *:$PORT>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    ServerAdmin $ADMIN_EMAIL
    DocumentRoot $WEB_ROOT

    ErrorLog \${APACHE_LOG_DIR}/$DOMAIN-error.log
    CustomLog \${APACHE_LOG_DIR}/$DOMAIN-access.log combined

    <Directory $WEB_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
    sudo a2ensite $DOMAIN.conf
    sudo systemctl reload apache2

else
    # Obter a versão ativa do PHP-FPM instalada para o Nginx
    PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')

    # Evita conflito com o bloco 'default' do Nginx se ele partilhar a mesma porta
    if [ -f /etc/nginx/sites-enabled/default ]; then
        if grep -q "listen $PORT" /etc/nginx/sites-enabled/default; then
            echo -e "${YELLOW}Aviso: Desativando o bloco default do Nginx pois colidia na porta $PORT.${NC}"
            sudo rm -f /etc/nginx/sites-enabled/default || true
        fi
    fi

    # Criar Server Block Nginx apontando para a pasta exclusiva
    sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen $PORT;
    listen [::]:$PORT;

    server_name $DOMAIN www.$DOMAIN;
    root $WEB_ROOT;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$PHP_VER-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    sudo systemctl reload nginx
fi

echo -e "${GREEN}[6/6] A configurar a Firewall (UFW) e a emitir SSL com Certbot...${NC}"

# Configuração e reencaminhamento automático na Firewall do Ubuntu (UFW)
if sudo ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}Firewall UFW detetada ativa. A permitir tráfego de entrada na porta $PORT...${NC}"
    sudo ufw allow $PORT/tcp comment "Permitir $WEB_SERVER $DOMAIN"
    sudo ufw reload
else
    echo -e "${BLUE}Firewall UFW desativada. Nenhuma abertura de porta manual foi necessária.${NC}"
fi

# Emissão do SSL (Recarregamento em modo zero-downtime)
if [ "$WEB_SERVER" == "apache" ]; then
    sudo certbot --apache -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect
    sudo systemctl reload apache2
else
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect
    sudo systemctl reload nginx
fi

echo -e "${GREEN}====================================================${NC}"
echo -e "${GREEN}Configuração concluída com sucesso!${NC}"
echo -e "Servidor Ativo: ${YELLOW}${WEB_SERVER^^}${NC}"
echo -e "Domínio configurado: ${YELLOW}https://$DOMAIN:$PORT${NC}"
echo -e "Pasta Isolada: ${YELLOW}$WEB_ROOT${NC}"
echo -e "Firewall: Autorizado tráfego TCP na porta ${YELLOW}$PORT${NC}"
echo -e "\n${BLUE}=== Estado da Renovação Automática (Background) ===${NC}"

# Verifica se o cron/timer do certbot está devidamente agendado no sistema
if systemctl is-active --quiet certbot.timer || systemctl is-active --quiet snap.certbot.renew.timer; then
    echo -e "${GREEN}✓ O agendador de renovação automática do Certbot está ativo no background.${NC}"
else
    echo -e "${YELLOW}⚠ Agendador do Certbot não detetado. A tentar agendar teste de renovação...${NC}"
    sudo certbot renew --dry-run
fi
echo -e "${GREEN}====================================================${NC}"
