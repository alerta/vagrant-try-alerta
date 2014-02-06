#!/bin/sh -e

set -x

VERSION=0.2.4

apt-get -y install openjdk-7-jre ruby-dev
cd /var/tmp
wget -nv http://aphyr.com/riemann/riemann_${VERSION}_all.deb
dpkg -i riemann_${VERSION}_all.deb

mv /etc/riemann/riemann.config /etc/riemann/riemann.config.bak
wget https://raw.github.com/alerta/riemann-alerta/master/riemann.config
cp riemann.config /etc/riemann/

wget https://raw.github.com/alerta/riemann-alerta/master/alerta.clj
cp alerta.clj /etc/riemann/

rm -f /etc/init.d/riemann
cp /vagrant/files/upstart-riemann.conf /etc/init/riemann.conf
initctl reload-configuration riemann
service riemann restart

# Nokogiri
apt-get -y install libxslt-dev libxml2-dev
gem install nokogiri -v '1.5.9' --no-ri --no-rdoc

gem install riemann-tools --no-ri --no-rdoc
riemann-health --host 127.0.0.1 --tag location=london --tag os=linux &
