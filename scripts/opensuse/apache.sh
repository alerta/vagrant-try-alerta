#!/usr/bin/env bash

BASE_URL=/api
VENV_ROOT=/opt/alerta

zypper --non-interactive install apache2 apache2-mod_wsgi-python3

cat >/srv/www/wsgi.py <<EOF
import os

def application(environ, start_response):
    os.environ['BASE_URL'] = environ.get('BASE_URL', '')
    from alerta import app as _application
    return _application(environ, start_response)
EOF

cat >/etc/apache2/conf.d/default.conf <<EOF
Listen 8080
<VirtualHost *:8080>
  ServerName localhost
  WSGIDaemonProcess alerta processes=5 threads=5 python-home=${VENV_ROOT}
  WSGIProcessGroup alerta
  # WSGIApplicationGroup %{GLOBAL}
  WSGIScriptAlias / /srv/www/wsgi.py
  WSGIPassAuthorization On
  SetEnv BASE_URL ${BASE_URL}
  <Directory /srv/www>
    Require all granted
  </Directory>
</VirtualHost>
<VirtualHost *:80>
  ProxyPass ${BASE_URL} http://localhost:8080
  ProxyPassReverse ${BASE_URL} http://localhost:8080
  DocumentRoot /srv/www/htdocs
</VirtualHost>
EOF

cd /srv/www/htdocs
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta*/app/* .

cat >/srv/www/htdocs/config.json <<EOF
{"endpoint": "${BASE_URL}"}
EOF

cat >/etc/apache2/conf.d/servername.conf <<EOF
ServerName localhost
EOF

a2enmod proxy
a2enmod proxy_http
systemctl restart apache2
systemctl enable apache2
