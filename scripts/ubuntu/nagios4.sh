#!/bin/sh -e

set -x

NAGIOS_CORE_VERSION=4.4.2
NAGIOS_PLUGINS_VERSION=2.2.1

# create user & group
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios

# download source
cd $HOME
wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_CORE_VERSION}.tar.gz
tar zxvf nagios-${NAGIOS_CORE_VERSION}.tar.gz
cd nagios-${NAGIOS_CORE_VERSION}

# build nagios
./configure --prefix=/usr/local/nagios --with-nagios-group=nagios --with-command-group=nagcmd
make all
make install
make install-commandmode
make install-init
make install-config

# install web interface
DEBIAN_FRONTEND=noninteractive apt-get -y install php libapache2-mod-php
/usr/bin/install -c -m 644 sample-config/httpd.conf /etc/apache2/sites-available/nagios.conf
ln -s /etc/apache2/sites-available/nagios.conf /etc/apache2/sites-enabled/
usermod -G nagcmd www-data
a2enmod rewrite
a2enmod cgi
htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin nagiosadmin
systemctl restart apache2

# install plugins
cd $HOME
wget http://www.nagios-plugins.org/download/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz
tar -xzf nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz
cd nagios-plugins-${NAGIOS_PLUGINS_VERSION}/

./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make all
make install

# install nagios-alerta NEB
DEBIAN_FRONTEND=noninteractive apt-get -y install libcurl4-openssl-dev libjansson-dev
cd $HOME
git clone https://github.com/alerta/nagios-alerta.git
cd nagios-alerta
make nagios4 && make install
echo "broker_module=/usr/lib/nagios/alerta-neb.o http://localhost:8080 debug=1" | tee -a /usr/local/nagios/etc/nagios.cfg

# configure monitoring
cd /usr/local/nagios/etc/objects
wget https://raw.github.com/alerta/nagios-alerta/master/config/nagios4-heartbeat.cfg
echo "cfg_file=/usr/local/nagios/etc/objects/nagios4-heartbeat.cfg" | tee -a /usr/local/nagios/etc/nagios.cfg

systemctl daemon-reload
service nagios restart
