#!/bin/sh -x

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install python3 python3-setuptools python3-pip python3-dev python3-venv libffi-dev

id alerta || (groupadd alerta && useradd -g alerta alerta)
cd /opt
python3 -m venv alerta
alerta/bin/pip install --upgrade pip wheel
alerta/bin/pip install alerta-server alerta

echo "PATH=$PATH:/opt/alerta/bin" >/etc/profile.d/alerta.sh

cat >>/etc/alertad.conf <<EOF
DEBUG=True
BASE_URL='/api'
SECRET_KEY='$(< /dev/urandom tr -dc A-Za-z0-9_\!\@\#\$\%\^\&\*\(\)-+= | head -c 32)'
PLUGINS=['reject', 'blackout']
EOF
