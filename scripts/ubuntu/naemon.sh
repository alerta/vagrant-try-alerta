#!/bin/sh -e

set -x

NAEMON_CORE_VERSION=1.0.8

addgroup --system naemon
adduser --system naemon
adduser naemon naemon

apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y install \
    libroot-core-dev \
    bsd-mailx \
    apache2 \
    apache2-utils \
    libapache2-mod-fcgid \
    libfontconfig1 \
    libjpeg62 \
    libgd3 \
    libxpm4 \
    xvfb \
    libmysqlclient20 \
    libglib2.0-dev

gpg --keyserver keys.gnupg.net --recv-keys F8C1CA08A57B9ED7
gpg --armor --export F8C1CA08A57B9ED7 | apt-key add -
echo "deb http://labs.consol.de/repo/stable/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/labs-consol-stable.list

apt-get update -y
apt-get install -y naemon nagios-plugins

# install nagios-alerta NEB
DEBIAN_FRONTEND=noninteractive apt-get -y install libcurl4-openssl-dev libjansson-dev
cd $HOME
git clone https://github.com/alerta/nagios-alerta.git
cd nagios-alerta
make naemon && make install

echo "broker_module=/usr/lib/nagios/alerta-neb.o http://localhost:8080 debug=1" | tee -a /etc/naemon/naemon.cfg

systemctl restart naemon
systemctl restart apache2

echo "http://192.168.0.112/naemon/"
echo "http://192.168.0.112/thruk/"   # thrukadmin/thrukadmin
echo "htpasswd /etc/thruk/htpasswd thrukadmin"
