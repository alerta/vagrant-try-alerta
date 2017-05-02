#!/bin/sh -e

set -x

NAGIOS_CORE_VERSION=4.1.1
NAGIOS_PLUGINS_VERSION=2.1.2

#echo “postfix postfix/main_mailer_type select No configuration” | debconf-set-selections
#echo “nagios3-cgi nagios4/adminpassword password nagiosadmin” | debconf-set-selections
#echo “nagios3-cgi nagios4/adminpassword-repeat password nagiosadmin” | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive
apt-get -y install libcurl4-openssl-dev

wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-${NAGIOS_CORE_VERSION}.tar.gz
tar zxvf nagios-${NAGIOS_CORE_VERSION}.tar.gz
cd nagios-${NAGIOS_CORE_VERSION}

groupadd -g 3000 nagios
groupadd -g 3001 nagcmd
useradd -u 3000 -g nagios -G nagcmd -d /usr/local/nagios -c 'Nagios Admin' nagios
adduser www-data nagcmd

./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios --with-command-user=nagios --with-command-group=nagcmd
make all
make install
sudo make install-init
sudo make install-config
sudo make install-commandmode

cd $HOME
wget http://www.nagios-plugins.org/download/nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz
tar -xzf nagios-plugins-${NAGIOS_PLUGINS_VERSION}.tar.gz
cd nagios-plugins-${NAGIOS_PLUGINS_VERSION}/

./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl
make all
make install

cd $HOME
git clone https://github.com/alerta/nagios-alerta.git
cd nagios-alerta
make nagios4 && make install
echo "broker_module=/usr/lib/nagios/alerta-neb.o http://localhost:8080 debug=1" | tee -a /usr/local/nagios/etc/nagios.cfg

cd /usr/local/nagios/etc/objects
wget https://raw.github.com/alerta/nagios-alerta/master/config/nagios4-heartbeat.cfg
echo "cfg_file=/usr/local/nagios/etc/objects/nagios4-heartbeat.cfg" | tee -a /usr/local/nagios/etc/nagios.cfg

systemctl daemon-reload
service nagios restart
