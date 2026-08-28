#!/bin/bash

# Executar como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, execute este script como root (sudo)."
  exit 1
fi

# 1. Detetar a versão atual do PHP instalada
if ! command -v php &> /dev/null; then
  echo "Erro: O PHP não está instalado neste servidor."
  exit 1
fi

# Extrai a versão maior.menor (Ex: 8.1, 8.2, 8.3)
PHP_VERSAO=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
PHP_FPM_SOCK="/var/run/php/php${PHP_VERSAO}-fpm.sock"

# Verificar se o serviço PHP-FPM existe
if [ ! -S "$PHP_FPM_SOCK" ]; then
  echo "Aviso: O socket PHP-FPM em $PHP_FPM_SOCK não foi encontrado."
  echo "Verifique se o serviço php${PHP_VERSAO}-fpm está em execução."
  exit 1
fi

# Variáveis do Site - Altere conforme necessário
DOMINIO="meusitephp.local"
PORTA="8081"
DIRETORIO_RAIZ="/var/www/meusitephp"

echo "=== Configurando Nginx + PHP $PHP_VERSAO ==="
echo "Site: $DOMINIO | Porta: $PORTA | Pasta: $DIRETORIO_RAIZ"

# 2. Criar a pasta do site
mkdir -p "$DIRETORIO_RAIZ"

# 3. Criar uma página PHP de teste (index.php)
cat <<EOF > "$DIRETORIO_RAIZ/index.php"
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>PHP Funcionando!</title>
    <style>
        body { font-family: sans-serif; text-align: center; margin-top: 5%; background: #f4f4f9; }
        .card { background: white; padding: 30px; border-radius: 8px; display: inline-block; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        h1 { color: #4F5B93; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Nginx + PHP $PHP_VERSAO</h1>
        <p>Configurado na porta <strong>$PORTA</strong> e na pasta <strong>$DIRETORIO_RAIZ</strong>.</p>
        <p>Hora do servidor: <?php echo date('H:i:s d/m/Y'); ?></p>
    </div>
</body>
</html>
EOF

# 4. Ajustar permissões
chown -R www-data:www-data "$DIRETORIO_RAIZ"
chmod -R 755 "$DIRETORIO_RAIZ"

# 5. Criar o ficheiro de configuração do Nginx com suporte a PHP
CONFIG_NGINX="/etc/nginx/sites-available/$DOMINIO"

cat <<EOF > "$CONFIG_NGINX"
server {
    listen $PORTA;
    listen [::]:$PORTA;

    server_name $DOMINIO;
    root $DIRETORIO_RAIZ;

    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }

    # Configuração do PHP-FPM
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:$PHP_FPM_SOCK;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    # Bloquear ficheiros ocultos (.htaccess, .git, etc)
    location ~ /\.ht {
        deny all;
    }
}
EOF

# 6. Ativar o site no Nginx
LINK_ATIVO="/etc/nginx/sites-enabled/$DOMINIO"
if [ ! -L "$LINK_ATIVO" ]; then
  ln -s "$CONFIG_NGINX" "$LINK_ATIVO"
fi

# 7. Testar e reiniciar o Nginx
nginx -t

if [ $? -eq 0 ]; then
  systemctl restart nginx
  echo "--------------------------------------------------------"
  echo "Sucesso! Aceda em: http://seu-ip-ou-dominio:$PORTA"
  echo "--------------------------------------------------------"
else
  echo "Erro na validação do Nginx. Verifique a configuração."
fi
