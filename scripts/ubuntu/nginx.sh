#!/bin/sh -x

BASE_URL=/api

DEBIAN_FRONTEND=noninteractive apt-get -y install nginx
/opt/alerta/bin/pip install uwsgi

cat >/var/www/wsgi.py <<EOF
from alerta import app
EOF

cat >/etc/uwsgi.ini <<EOF
[uwsgi]
chdir = /var/www
mount = ${BASE_URL}=wsgi.py
callable = app
manage-script-name = true
env = BASE_URL=${BASE_URL}

master = true
processes = 5
logger = syslog:alertad

socket = /tmp/uwsgi.sock
chmod-socket = 664
uid = www-data
gid = www-data
vacuum = true

die-on-term = true
EOF

cat >/etc/systemd/system/uwsgi.service <<EOF
[Unit]
Description=uWSGI service

[Service]
ExecStart=/opt/alerta/bin/uwsgi --ini /etc/uwsgi.ini

[Install]
WantedBy=multi-user.target
EOF

service uwsgi restart

cat >/etc/nginx/sites-enabled/default <<EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        location ${BASE_URL} { try_files \$uri @api; }
        location @api {
            include uwsgi_params;
            uwsgi_pass unix:/tmp/uwsgi.sock;
            proxy_set_header Host \$host:\$server_port;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }

        root   /usr/share/nginx/html;

        location / {
            try_files \$uri \$uri/ /index.html;
        }
}
EOF

cd /tmp
wget -q -O - https://github.com/alerta/alerta-webui/releases/latest/download/alerta-webui.tar.gz | tar zxf -
cp -R /tmp/dist/* /usr/share/nginx/html

cat >/usr/share/nginx/html/config.json <<EOF
{"endpoint": "${BASE_URL}"}
EOF

service nginx restart
