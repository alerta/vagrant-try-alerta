#!/bin/sh -e

set -x

#echo “postfix postfix/main_mailer_type select No configuration” | debconf-set-selections
#echo “nagios3-cgi nagios4/adminpassword password nagiosadmin” | debconf-set-selections
#echo “nagios3-cgi nagios4/adminpassword-repeat password nagiosadmin” | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive
apt-get -y install libcurl4-openssl-dev

wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
tar zxvf nagios-4.1.1.tar.gz
cd nagios-4.1.1

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

/usr/local/nagios/bin/nagios /usr/local/nagios/etc/nagios.cfg

wget http://www.nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz

git clone https://github.com/alerta/nagios-alerta.git
cd nagios-alerta
make nagios4 && make install
echo "broker_module=/usr/lib/nagios/alerta-neb.o http://localhost:8080 debug=1" | tee -a /usr/local/nagios/etc/nagios.cfg

cd /etc/nagios/conf.d
wget https://raw.github.com/alerta/nagios3-alerta/master/config/nagios-heartbeat.cfg
service nagios restart
