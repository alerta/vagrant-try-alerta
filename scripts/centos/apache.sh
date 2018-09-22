#!/bin/sh -x

VENV_ROOT=/opt/alerta

yum -y install httpd httpd-devel
/opt/alerta/bin/pip install mod-wsgi
mod_wsgi-express install-module > /etc/httpd/conf.modules.d/02-wsgi.conf
/usr/sbin/setsebool -P httpd_can_network_connect 1

cat >/var/www/wsgi.py << EOF
import os

def application(environ, start_response):
    os.environ['BASE_URL'] = environ.get('BASE_URL', '')
    from alerta import app as _application
    return _application(environ, start_response)
EOF

cat >/etc/httpd/conf.d/default.conf << EOF
Listen 8080
<VirtualHost *:8080>
  ServerName localhost
  WSGIDaemonProcess alerta processes=5 threads=5 python-home=${VENV_ROOT}
  WSGIProcessGroup alerta
  # WSGIApplicationGroup %{GLOBAL}
  WSGIScriptAlias / /var/www/wsgi.py
  WSGIPassAuthorization On
  SetEnv BASE_URL /api
</VirtualHost>
<VirtualHost *:80>
  ProxyPass /api http://localhost:8080
  ProxyPassReverse /api http://localhost:8080
  DocumentRoot /var/www/html
</VirtualHost>
EOF

cd /var/www/html
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta*/app/* .

cat >/var/www/html/config.json <<EOF
{"endpoint": "/api"}
EOF

echo "ServerName localhost" >> /etc/httpd/conf.d/servername.conf

systemctl restart httpd
