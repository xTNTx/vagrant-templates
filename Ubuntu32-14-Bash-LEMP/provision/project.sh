#!/usr/bin/env bash
set -x
export DEBIAN_FRONTEND=noninteractive

PROJECT=$1
WEB_ROOT=$2
if [ ! -n "$PROJECT" ]; then
    echo "Project name argument is missing!"
    exit 1
fi
if [ ! -n "$WEB_ROOT" ]; then
    echo "Web root argument is missing!"
    exit 1
fi

echo "Setup Nginx ..."
echo "server {
    listen 80 default_server;
    listen [::]:80 default_server ipv6only=on;

    server_name $PROJECT.loc;
    root $WEB_ROOT;

    index index.php index.html index.htm;
    charset utf-8;

    access_log off;
    error_log  /var/log/nginx/error.log error;

    location = /favicon.ico {
        return 204;
        access_log off;
        log_not_found off;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;

        # Increase timeout for xdebugging
        fastcgi_read_timeout 15m;
    }
}
" > /etc/nginx/sites-available/default.conf
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled
service nginx restart

echo "Setup DB ..."
mysql -e "CREATE DATABASE \`$PROJECT\`;"
if [ -f /vagrant/dump.sql ]; then
    mysql $PROJECT < /vagrant/dump.sql
fi
