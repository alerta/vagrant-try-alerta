#!/bin/sh -e

set -x

export AUTH_REQUIRED=False

zypper install -y --force-resolution python3-pip python3-setuptools python3-virtualenv
zypper install -y --force-resolution apache2 apache2-mod_wsgi-python3 mongodb-server
pip install --upgrade pip setuptools wheel virtualenv

# disable mongodb authentication for development environment
sed -i 's/authorization: enabled/authorization: disabled/' /etc/mongodb.conf

systemctl restart mongodb
systemctl enable mongodb

id alerta || (groupadd alerta && useradd -g alerta alerta)
cd /opt
virtualenv alerta
alerta/bin/pip install alerta alerta-server
echo "PATH=$PATH:/opt/alerta/bin" >/etc/profile.d/alerta.sh

cat >/etc/apache2/conf.d/alerta.conf << EOF
Listen 8080
<VirtualHost *:8080>
  ServerName localhost
  WSGIDaemonProcess alerta processes=5 threads=5
  WSGIScriptAlias / /srv/www/api.wsgi
  WSGIProcessGroup alerta
  WSGIApplicationGroup %{GLOBAL}
  WSGIPassAuthorization On
  <Directory /srv/www>
    Require all granted
  </Directory>
  <Directory /opt/alerta>
    Require all granted
  </Directory>
</VirtualHost>
<VirtualHost *:80>
  ProxyPass /api http://localhost:8080
  ProxyPassReverse /api http://localhost:8080
</VirtualHost>
EOF

cat >/etc/apache2/conf.d/servername.conf << EOF
ServerName localhost
EOF

cat >/srv/www/api.wsgi << EOF
#!/opt/alerta/bin/python3

def execfile(filename):
    globals = dict( __file__ = filename )
    exec( open(filename).read(), globals )

activate_this = '/opt/alerta/bin/activate_this.py'
execfile(activate_this)
from alerta import app as application
EOF

cat >/etc/alertad.conf << EOF
SECRET_KEY = '$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
AUTH_REQUIRED = $AUTH_REQUIRED
PLUGINS = ['reject','blackout']
EOF

cd /srv/www
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta-angular-alerta-webui-*/app/* htdocs
rm -Rf alerta-angular-alerta-webui-*

cat >/srv/www/htdocs/config.js << EOF
'use strict';
angular.module('config', [])
  .constant('config', {
    'endpoint'    : "/api",
    'provider'    : "basic"
  })
  .constant('colors', {});
EOF

a2enmod proxy
a2enmod proxy_http
systemctl restart apache2
systemctl enable apache2
