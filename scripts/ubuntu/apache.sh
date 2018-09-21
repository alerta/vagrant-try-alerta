#!/bin/sh -x

VENV_ROOT=/opt/alerta

DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-wsgi-py3

cat >/var/www/api.wsgi << EOF
from alerta import app as application
EOF

cat >/etc/apache2/sites-available/000-default.conf << EOF
Listen 8080
<VirtualHost *:8080>
  ServerName localhost
  WSGIDaemonProcess alerta processes=5 threads=5 python-home=${VENV_ROOT}
  WSGIProcessGroup alerta
  # WSGIApplicationGroup %{GLOBAL}
  WSGIScriptAlias / /var/www/api.wsgi
  WSGIPassAuthorization On
</VirtualHost>
<VirtualHost *:80>
  ProxyPass /api http://localhost:8080
  ProxyPassReverse /api http://localhost:8080
  DocumentRoot /var/www/alerta/app
</VirtualHost>
EOF

cd /var/www
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta-* alerta

cat >/var/www/alerta/app/config.json <<EOF
{"endpoint": "/api"}
EOF

echo "ServerName localhost" >> /etc/apache2/apache2.conf
a2enmod proxy_http
service apache2 reload
