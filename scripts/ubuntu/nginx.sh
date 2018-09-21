#!/bin/sh -x

DEBIAN_FRONTEND=noninteractive apt-get -y install nginx
/opt/alerta/bin/pip install uwsgi

cat >/var/www/wsgi.py <<EOF
from alerta import app
EOF

cat >/etc/uwsgi.ini <<EOF
[uwsgi]
chdir = /var/www
mount = /api=wsgi.py
callable = app
manage-script-name = true
env = BASE_URL=/api

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

cat >/etc/nginx/sites-enabled/default <<'HERE'
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        location /api { try_files $uri @api; }
        location @api {
            include uwsgi_params;
            uwsgi_pass unix:/tmp/uwsgi.sock;
            proxy_set_header Host $host:$server_port;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }

        location / {
                root /var/www/html;
        }
}
HERE

cd /var/www/html
wget -q -O - https://github.com/alerta/angular-alerta-webui/tarball/master | tar zxf -
mv alerta*/app/* .

cat >/var/www/html/config.json <<EOF
{"endpoint": "/api"}
EOF

service nginx restart
