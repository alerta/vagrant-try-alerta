
#!/bin/sh -e

set -x

# create user & group
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios

# install nagios3 and dependencies
DEBIAN_FRONTEND=noninteractive apt-get -y install nagios3 nagios-nrpe-plugin

# install web interface
#DEBIAN_FRONTEND=noninteractive apt-get -y install php libapache2-mod-php

a2enmod rewrite
a2enmod cgi
htpasswd -bc /etc/nagios3/htpasswd.users nagiosadmin nagiosadmin
systemctl restart apache2

# install nagios-alerta NEB
DEBIAN_FRONTEND=noninteractive apt-get -y install libcurl4-openssl-dev libjansson-dev
cd $HOME
git clone https://github.com/alerta/nagios-alerta.git
cd nagios-alerta
make nagios3 && make install
echo "broker_module=/usr/lib/nagios/alerta-neb.o http://localhost:8080 debug=1" | tee -a /etc/nagios3/nagios.cfg

# configure monitoring
cd /etc/nagios3/conf.d/
wget https://raw.github.com/alerta/nagios-alerta/master/config/nagios3-heartbeat.cfg

systemctl daemon-reload
service nagios3 restart
