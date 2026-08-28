#!/bin/bash

# Interromper se ocorrer algum erro inesperado em comandos críticos
# (Desativado globalmente para o menu não fechar ao errar inputs)
set +e

# Cores para o interface
GREEN='\033;32m'
YELLOW='\033[1;33m'
BLUE='\033;0;34m'
RED='\033;0;31m'
NC='\033[0m'

# Função utilitária para pausar o ecrã
pausa() {
    echo -e "\n${YELLOW}Pressione [Enter] para continuar...${NC}"
    read -r
}

# Função para detetar o servidor web ativo
detetar_servidor() {
    if command -v apache2 >/dev/null 2>&1; then
        echo "apache"
    elif command -v nginx >/dev/null 2>&1; then
        echo "nginx"
    else
        echo "nenhum"
    fi
}

# =====================================================================
# SUBMENU 1: CONFIGURAÇÃO DO NOVO DOMÍNIO
# =====================================================================
configurar_novo_dominio() {
    clear
    echo -e "${BLUE}=== [SUBMENU] Configurar Novo Domínio Isolado ===${NC}\n"
    
    WEB_SERVER=$(detetar_servidor)
    if [ "$WEB_SERVER" == "nenhum" ]; then
        echo -e "${RED}Erro: Não foi detetado o Apache nem o Nginx instalado neste sistema.${NC}"
        pausa
        return
    fi

    echo -e "Servidor Web detetado: ${GREEN}${WEB_SERVER^^}${NC}\n"

    read -p "$(echo -e ${YELLOW}"Introduza o Domínio [padrão: secure.ospro.pt]: "${NC})" INPUT_DOMAIN
    DOMAIN=${INPUT_DOMAIN:-"secure.ospro.pt"}
    WEB_ROOT="/var/www/$DOMAIN"

    while true; do
        read -p "$(echo -e ${YELLOW}"Introduza a Porta pretendida [padrão: 8123]: "${NC})" INPUT_PORT
        PORT=${INPUT_PORT:-"8123"}
        PORT_CHECK=$(sudo ss -tlnp | grep -E "[: ]${PORT} " || true)

        if [ -n "$PORT_CHECK" ]; then
            PROCESS_NAME=$(echo "$PORT_CHECK" | awk '{print $NF}' | cut -d'"' -f2 | head -n 1)
            echo -e "${RED}Erro: A porta $PORT já está ocupada pelo processo: [${PROCESS_NAME}].${NC}"
            echo -e "${YELLOW}Escolha outra porta para evitar conflitos.${NC}\n"
        else
            echo -e "${GREEN}Sucesso: A porta $PORT está livre e disponível.${NC}"
            break
        fi
    done

    read -p "$(echo -e ${YELLOW}"Introduza o IP do Servidor [padrão: 51.158.97.92]: "${NC})" INPUT_IP
    SERVER_IP=${INPUT_IP:-"51.158.97.92"}

    read -p "$(echo -e ${YELLOW}"Introduza o Email de Administração [padrão: admin@ospro.pt]: "${NC})" INPUT_EMAIL
    ADMIN_EMAIL=${INPUT_EMAIL:-"admin@ospro.pt"}

    echo -e "\n${GREEN}A aplicar configurações (Zero Downtime)...${NC}"
    sudo apt update && sudo apt upgrade -y > /dev/null

    if [ "$WEB_SERVER" == "apache" ]; then
        sudo apt install certbot python3-certbot-apache php php-cli php-common php-curl php-gd php-mbstring php-xml php-zip php-mysql php-intl libapache2-mod-php -y > /dev/null
        sudo a2enmod rewrite ssl > /dev/null
        if ! grep -q "Listen $PORT" /etc/apache2/ports.conf; then
            echo "Listen $PORT" | sudo tee -a /etc/apache2/ports.conf > /dev/null
        fi
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
        sudo mkdir -p "$WEB_ROOT"
        sudo chown -R $USER:www-data "$WEB_ROOT"
        sudo chmod -R 755 "$WEB_ROOT"
        if [ ! -f "$WEB_ROOT/index.php" ]; then
            echo "<?php echo '<h1>Ambiente Isolado Apache na porta '$PORT.'</h1>'; ?>" | sudo tee "$WEB_ROOT/index.php" > /dev/null
        fi
        sudo a2ensite $DOMAIN.conf > /dev/null
        sudo systemctl reload apache2
        sudo certbot --apache -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect || true
        sudo systemctl reload apache2
    else
        sudo apt install certbot python3-certbot-nginx php php-cli php-common php-curl php-gd php-mbstring php-xml php-zip php-mysql php-intl php-fpm -y > /dev/null
        PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
        if [ -f /etc/nginx/sites-enabled/default ] && grep -q "listen $PORT" /etc/nginx/sites-enabled/default; then
            sudo rm -f /etc/nginx/sites-enabled/default || true
        fi
        sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen $PORT;
    listen [::]:$PORT;
    server_name $DOMAIN www.$DOMAIN;
    root $WEB_ROOT;
    index index.php index.html index.htm;
    location / { try_files \$uri \$uri/ =404; }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php$PHP_VER-fpm.sock;
    }
    location ~ /\.ht { deny all; }
}
EOF
        sudo mkdir -p "$WEB_ROOT"
        sudo chown -R $USER:www-data "$WEB_ROOT"
        sudo chmod -R 755 "$WEB_ROOT"
        if [ ! -f "$WEB_ROOT/index.php" ]; then
            echo "<?php echo '<h1>Ambiente Isolado Nginx na porta '$PORT.'</h1>'; ?>" | sudo tee "$WEB_ROOT/index.php" > /dev/null
        fi
        sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
        sudo systemctl reload nginx
        sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $ADMIN_EMAIL --redirect || true
        sudo systemctl reload nginx
    fi

    if sudo ufw status | grep -q "Status: active"; then
        sudo ufw allow $PORT/tcp comment "Permitir $WEB_SERVER $DOMAIN" > /dev/null
        sudo ufw reload > /dev/null
    fi

    echo -e "\n${GREEN}✔ Configuração concluída com sucesso!${NC}"
    echo -e "Aceda a: ${YELLOW}https://$DOMAIN:$PORT${NC}"
    pausa
}

# =====================================================================
# SUBMENU 2: GESTÃO DO CERTBOT / SSL
# =====================================================================
menu_ssl() {
    while true; do
        clear
        echo -e "${BLUE}=== [SUBMENU] Gestão de Certificados SSL (Certbot) ===${NC}"
        echo -e "1) Verificar Estado dos Certificados Ativos"
        echo -e "2) Testar Renovação Automática (Dry-Run)"
        echo -e "3) Forçar Renovação Manual de todos os SSL"
        echo -e "4) Verificar Estado do Agendador (Systemd Timer)"
        echo -e "0) Voltar ao Menu Principal"
        read -p "Escolha uma opção: " OP_SSL

        case $OP_SSL in
            1) clear; sudo certbot certificates; pausa ;;
            2) clear; echo -e "${YELLOW}A simular renovação em background...${NC}"; sudo certbot renew --dry-run; pausa ;;
            3) clear; echo -e "${GREEN}A renovar certificados expirados...${NC}"; sudo certbot renew; pausa ;;
            4) 
                clear
                if systemctl is-active --quiet certbot.timer || systemctl is-active --quiet snap.certbot.renew.timer; then
                    echo -e "${GREEN}✓ O agendador em background está ativo e saudável.${NC}"
                else
                    echo -e "${RED}⚠ O agendador automático está desligado.${NC}"
                fi
                pausa 
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}"; sleep 1 ;;
        esac
    done
}

# =====================================================================
# SUBMENU 3: GESTÃO DA FIREWALL (UFW)
# =====================================================================
menu_firewall() {
    while true; do
        clear
        echo -e "${BLUE}=== [SUBMENU] Gestão da Firewall UFW ===${NC}"
        echo -e "1) Ver Estado Atual e Portas Abertas"
        echo -e "2) Abrir uma Nova Porta Customizada"
        echo -e "3) Fechar/Bloquear uma Porta"
        echo -e "4) Ligar / Desligar Firewall completamente"
        echo -e "0) Voltar ao Menu Principal"
        read -p "Escolha uma opção: " OP_FW

        case $OP_FW in
            1) clear; sudo ufw status numbered; pausa ;;
            2) 
                clear
                read -p "Introduza a porta que quer abrir (ex: 8080): " P_OPEN
                sudo ufw allow "$P_OPEN"/tcp comment "Manual: Porta $P_OPEN"
                sudo ufw reload
                echo -e "${GREEN}Porta $P_OPEN aberta com sucesso!${NC}"
                pausa 
                ;;
            3) 
                clear
                sudo ufw status numbered
                read -p "Introduza o NÚMERO da regra que quer apagar (ex: 1): " P_DEL
                sudo ufw delete "$P_DEL"
                sudo ufw reload
                pausa 
                ;;
            4)
                clear
                if sudo ufw status | grep -q "Status: active"; then
                    sudo ufw disable
                    echo -e "${RED}Firewall Desativada!${NC}"
                else
                    sudo ufw enable
                    echo -e "${GREEN}Firewall Ativada com Sucesso!${NC}"
                fi
                pausa
                ;;
            0) break ;;
            *) echo -e "${RED}Opção inválida!${NC}"; sleep 1 ;;
        esac
    done
}

# =====================================================================
# MENU PRINCIPAL
# =====================================================================
while true; do
    clear
    echo -e "${BLUE}=====================================================${NC}"
    echo -e "${BLUE}     SISTEMA DE GESTÃO WEB - SERVIDORES ISOLADOS     ${NC}"
    echo -e "${BLUE}=====================================================${NC}"
    echo -e "1) ${GREEN}Configurar Novo Domínio Isolado (Porta Dedicada)${NC}"
    echo -e "2) Gerir Certificados SSL & Agendador Certbot"
    echo -e "3) Gerir Regras e Portas da Firewall (UFW)"
    echo -e "4) Verificar Portas Ocupadas no Sistema (ss)"
    echo -e "5) Estado Geral dos Serviços (Apache/Nginx/PHP)"
    echo -e "0) Sair do Script"
    echo -e "${BLUE}=====================================================${NC}"
    read -p "Selecione a opção pretendida: " OP_MAIN

