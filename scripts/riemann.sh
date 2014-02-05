#!/bin/sh -e

VERSION=0.2.4

sudo apt-get -y install openjdk-7-jre

cd /var/tmp
wget http://aphyr.com/riemann/riemann_${VERSION}_all.deb
sudo dpkg -i riemann_${VERSION}_all.deb

sudo mv /etc/riemann/riemann.config{,.bak}
wget https://raw.github.com/alerta/riemann-alerta/master/riemann.config
sudo cp riemann.config /etc/riemann/

wget https://raw.github.com/alerta/riemann-alerta/master/alerta.clj
sudo cp alerta.clj /etc/riemann/

sudo service riemann restart
