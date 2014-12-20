#!/bin/sh -e

set -x

export AUTH_REQUIRED=False
export CLIENT_ID=not-set
export REDIRECT_URL=not-set
export ALLOWED_EMAIL_DOMAIN=*

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install git wget build-essential python python-setuptools python-pip python-dev python-virtualenv
DEBIAN_FRONTEND=noninteractive apt-get -y install mongodb-server apache2 libapache2-mod-wsgi

grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | tee -a /etc/mongodb.conf
service mongodb restart

id alerta || (groupadd alerta && useradd -g alerta alerta)
cd /opt
virtualenv alerta
alerta/bin/pip install alerta-server
echo "PATH=$PATH:/opt/alerta/bin" >/etc/profile.d/alerta.sh

cat >/etc/apache2/sites-available/000-default.conf << EOF
Listen 8080
<VirtualHost *:8080>
   ServerName localhost
   WSGIDaemonProcess alerta processes=5 threads=5
   WSGIProcessGroup alerta
   WSGIScriptAlias / /var/www/api.wsgi
   WSGIPassAuthorization On
   <Directory /opt/alerta>
     WSGIApplicationGroup %{GLOBAL}
     Require all granted
   </Directory>
</VirtualHost>
<VirtualHost *:80>
   DocumentRoot /var/www/html
   <Directory /var/www/html>
     Require all granted
   </Directory>
</VirtualHost>
EOF

cat >/var/www/api.wsgi << EOF
#!/usr/bin/env python
activate_this = '/opt/alerta/bin/activate_this.py'
execfile(activate_this, dict(__file__=activate_this))
from alerta.app import app as application
EOF

cat >/etc/alertad.conf << EOF
DEBUG = True
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
AUTH_REQUIRED = $AUTH_REQUIRED
OAUTH2_CLIENT_ID = '$CLIENT_ID'
ALLOWED_EMAIL_DOMAINS = ['$ALLOWED_EMAIL_DOMAIN']
PLUGINS = ['reject']
EOF

echo "ServerName localhost" >> /etc/apache2/apache2.conf
service apache2 reload

cd /var/www && rm -Rf html/*
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta-angular-alerta-webui-*/app/* html
rm -Rf alerta-angular-alerta-webui-*

cat >/var/www/html/config.js << EOF
'use strict';
angular.module('config', [])
  .constant('config', {
    'endpoint'    : "http://"+window.location.hostname+":8080",
    'client_id'   : "$CLIENT_ID",
    'redirect_url': "$REDIRECT_URL"
  });
EOF
