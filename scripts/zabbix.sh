#!/bin/sh -e

# Zabbix: http://192.168.0.102/zabbix
# Username: Admin
# Password: zabbix

set -x

wget http://repo.zabbix.com/zabbix/2.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_2.2-1+trusty_all.deb
dpkg -i zabbix-release_2.2-1+trusty_all.deb
apt-get -y update

export DEBIAN_FRONTEND=noninteractive
apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-sender

echo "START=yes" >> /etc/default/zabbix-server
service zabbix-server start

echo "date.timezone = Europe/London" >> /etc/php5/apache2/php.ini
service apache2 restart

wget https://raw.github.com/alerta/zabbix-alerta/master/zabbix_alerta.py
cp zabbix_alerta.py /usr/lib/zabbix/alertscripts
chmod 755 /usr/lib/zabbix/alertscripts/zabbix_alerta.py
