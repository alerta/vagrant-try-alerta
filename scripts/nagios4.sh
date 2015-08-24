#!/bin/sh -e

set -x

echo “postfix postfix/main_mailer_type select No configuration” | debconf-set-selections
echo “nagios3-cgi nagios4/adminpassword password nagiosadmin” | debconf-set-selections
echo “nagios3-cgi nagios4/adminpassword-repeat password nagiosadmin” | debconf-set-selections

export DEBIAN_FRONTEND=noninteractive
apt-get -y install nagios3 nagios-nrpe-plugin libcurl4-openssl-dev

git clone https://github.com/alerta/nagios-alerta.git
cd nagios3-alerta
make nagios4 && make install
echo "broker_module=/usr/lib/nagios/alerta-neb.o http://localhost:8080 debug=1" | tee -a /etc/nagios3/nagios.cfg

cd /etc/nagios3/conf.d
wget https://raw.github.com/alerta/nagios3-alerta/master/config/nagios3-heartbeat.cfg
service nagios3 restart

