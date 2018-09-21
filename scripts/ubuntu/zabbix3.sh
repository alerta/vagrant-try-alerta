#!/bin/sh -e

# Zabbix: http://192.168.0.110/zabbix
# Username: Admin
# Password: zabbix

set -x

wget http://repo.zabbix.com/zabbix/3.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_3.0-1+trusty_all.deb
dpkg -i zabbix-release_3.0-1+trusty_all.deb
apt-get -y update

export DEBIAN_FRONTEND=noninteractive
apt-get -y install zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-sender

echo "create database zabbix character set utf8 collate utf8_bin;" | mysql -uroot
echo "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';" | mysql -uroot

cd /usr/share/doc/zabbix-server-mysql
zcat create.sql.gz | mysql -uroot zabbix

cat >>/etc/zabbix/zabbix_server.conf <<EOF
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
EOF

echo "START=yes" >> /etc/default/zabbix-server
service zabbix-server start

cat >>/etc/php5/apache2/php.ini <<EOF
php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value always_populate_raw_post_data -1
date.timezone = Europe/London
EOF

service apache2 restart

wget https://raw.github.com/alerta/zabbix-alerta/master/zabbix_alerta.py
cp zabbix_alerta.py /usr/lib/zabbix/alertscripts
chmod 755 /usr/lib/zabbix/alertscripts/zabbix_alerta.py

