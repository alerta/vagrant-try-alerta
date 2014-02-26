#!/bin/sh -x

wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
apt-get -y update
apt-get -y install redis-server sensu

cd /etc/sensu/conf.d
wget https://raw.githubusercontent.com/alerta/vagrant-try-alerta/master/files/sensu.api.json
wget https://raw.githubusercontent.com/alerta/vagrant-try-alerta/master/files/sensu.dashboard.json
wget https://raw.githubusercontent.com/alerta/vagrant-try-alerta/master/files/sensu.redis.json
wget https://raw.githubusercontent.com/alerta/vagrant-try-alerta/master/files/sensu.client.json
wget https://raw.githubusercontent.com/alerta/vagrant-try-alerta/master/files/sensu.rabbitmq.json

update-rc.d sensu-server defaults
update-rc.d sensu-client defaults
update-rc.d sensu-api defaults
update-rc.d sensu-dashboard defaults

/etc/init.d/sensu-server start
/etc/init.d/sensu-client start
/etc/init.d/sensu-api start
/etc/init.d/sensu-dashboard start

echo "Sensu dashboard... http://admin:secret@192.168.0.104:8080/"
