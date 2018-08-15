#!/bin/sh -e

set -x

export AUTH_REQUIRED=False

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install git wget build-essential python3 python3-setuptools python3-pip python3-dev python3-venv libffi-dev
DEBIAN_FRONTEND=noninteractive apt-get -y install mongodb-server nginx uwsgi uwsgi-plugin-python3

grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | tee -a /etc/mongodb.conf
service mongodb restart

id alerta || (groupadd alerta && useradd -g alerta alerta)
cd /opt
python3 -m venv alerta
alerta/bin/pip install --upgrade pip wheel alerta-server alerta
echo "PATH=$PATH:/opt/alerta/bin" >/etc/profile.d/alerta.sh

cat >/etc/nginx
user www-data;
worker_processes 4;
pid /run/nginx.pid;

daemon off;
error_log /dev/stdout info;

events {
        worker_connections 768;
        # multi_accept on;
}

http {

        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        # server_tokens off;

        # server_names_hash_bucket_size 64;
        # server_name_in_redirect off;

        include /etc/nginx/mime.types;
        default_type application/octet-stream;

        gzip on;
        gzip_disable "msie6";

        log_format main 'ip=\$http_x_real_ip [\$time_local] '
        '"\$request" \$status \$body_bytes_sent "\$http_referer" '
        '"\$http_user_agent"' ;

        upstream backend {
                server unix:/app.sock fail_timeout=0;
        }

        server {

                listen 80 default_server deferred;

                access_log /dev/stdout main;

    		location /api/ {
        		include uwsgi_params;
        		uwsgi_pass backend;
    		}
                location / {
                        root /var/www/html;
                }
        }
}
EOF

cat >/var/www/api.wsgi << EOF
from alerta.app import app as application
EOF

cat >/etc/alertad.conf << EOF
BASE_URL='/api'
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
AUTH_REQUIRED = $AUTH_REQUIRED
PLUGINS = ['reject']
EOF

echo "ServerName localhost" >> /etc/apache2/apache2.conf
a2enmod proxy_http
service apache2 reload

cd /var/www && rm -Rf html/*
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta-angular-alerta-webui-*/app/* html
rm -Rf alerta-angular-alerta-webui-*

cat >/var/www/html/config.js << EOF
'use strict';
angular.module('config', [])
  .constant('config', {
    'endpoint'    : "/api",
    'provider'    : "basic"
  })
  .constant('colors', {});
EOF
