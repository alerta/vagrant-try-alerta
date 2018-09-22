#!/bin/sh -e

yum -y install python36 python36-pip python36-devel python36-setuptools python36-venv libffi-devel

id alerta || (groupadd alerta && useradd -g alerta alerta)
cd /opt
python36 -m venv alerta
alerta/bin/pip install --upgrade pip wheel
alerta/bin/pip install alerta-server alerta

cat >>/etc/profile.d/alerta.sh <<EOF
PATH=$PATH:/opt/alerta/bin
EOF

cat >/etc/alertad.conf <<EOF
DEBUG=True
TESTING=True
SECRET_KEY='$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
PLUGINS=['reject', 'blackout']
DATABASE_URL='${DATABASE_URL}'
JSON_AS_ASCII=False
JSON_SORT_KEYS=True
JSONIFY_PRETTYPRINT_REGULAR=True
EOF

cat >$HOME/.alerta.conf <<EOF
[DEFAULT]
endpoint = http://localhost/api
EOF
