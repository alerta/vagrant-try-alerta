#!/bin/sh -e

set -x

VERSION=0.2.4

sudo apt-get -y install openjdk-7-jre ruby-dev

cd /var/tmp
wget -nv http://aphyr.com/riemann/riemann_${VERSION}_all.deb
sudo dpkg -i riemann_${VERSION}_all.deb

sudo mv /etc/riemann/riemann.config /etc/riemann/riemann.config.bak
wget https://raw.github.com/alerta/riemann-alerta/master/riemann.config
sudo cp riemann.config /etc/riemann/

wget https://raw.github.com/alerta/riemann-alerta/master/alerta.clj
sudo cp alerta.clj /etc/riemann/

sudo service riemann restart

sudo gem install riemann-tools -no-ri -no-rdoc
riemann-health --host 127.0.0.1 &
