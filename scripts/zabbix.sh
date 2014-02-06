#!/bin/sh -e

set -x

curl http://repo.zabbix.com/zabbix-official-repo.key | apt-key add -
echo "deb http://repo.zabbix.com/zabbix/2.2/debian wheezy main" >> /etc/apt/sources.list

apt-get update
export DEBIAN_FRONTEND=noninteractive
apt-get -y install snmp snmpd snmptt libsnmp15 libsnmp-base libsnmp-dev mysql-server
apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-sender

echo "START=yes" >> /etc/default/zabbix-server
service zabbix-server start

echo "date.timezone = Europe/London" >> /etc/php5/apache2/php.ini
service apache2 restart

wget https://raw.github.com/alerta/zabbix-alerta/master/zabbix_alerta.py
cp zabbix_alerta.py /usr/lib/zabbix/alertscripts
chmod 755 /usr/lib/zabbix/alertscripts/zabbix_alerta.py

