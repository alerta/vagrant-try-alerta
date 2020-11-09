#!/bin/sh -x

BASE_URL=/api
VENV_ROOT=/opt/alerta

DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 libapache2-mod-wsgi-py3

cat >/var/www/wsgi.py <<EOF
import os

def application(environ, start_response):
    os.environ['BASE_URL'] = environ.get('BASE_URL', '')
    from alerta import create_app
    _application = create_app()
    return _application(environ, start_response)
EOF

cat >/etc/apache2/sites-available/000-default.conf <<EOF
Listen 8080
<VirtualHost *:8080>
  ServerName localhost
  WSGIDaemonProcess alerta processes=5 threads=5 python-home=${VENV_ROOT}
  WSGIProcessGroup alerta
  # WSGIApplicationGroup %{GLOBAL}
  WSGIScriptAlias / /var/www/wsgi.py
  WSGIPassAuthorization On
  SetEnv BASE_URL ${BASE_URL}
</VirtualHost>
<VirtualHost *:80>
  ProxyPass ${BASE_URL} http://localhost:8080
  ProxyPassReverse ${BASE_URL} http://localhost:8080
  DocumentRoot /var/www/html
</VirtualHost>
EOF

cd /tmp
wget -q -O - https://github.com/alerta/alerta-webui/releases/latest/download/alerta-webui.tar.gz | tar zxf -
cp -R /tmp/dist/* /var/www/html

cat >/var/www/html/config.json <<EOF
{"endpoint": "${BASE_URL}"}
EOF

echo "ServerName localhost" >> /etc/apache2/apache2.conf
a2enmod proxy_http
apachectl restart
