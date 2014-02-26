#!/bin/sh

# set -x

wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
apt-get -y update
apt-get -y install redis-server sensu

wget -O /etc/sensu/conf.d/api.json https://raw.githubusercontent.com/alerta/vagrant-try-alerta/master/files/sensu.api.json
wget -O /etc/sensu/conf.d/dashboard.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.dashboard.json
wget -O /etc/sensu/conf.d/redis.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.redis.json
wget -O /etc/sensu/conf.d/client.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.client.json
wget -O /etc/sensu/conf.d/rabbitmq.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.rabbitmq.json

wget -O /etc/sensu/handlers/alerta.rb https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.alerta.rb
wget -O /etc/sensu/conf.d/alerta.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.alerta.json

update-rc.d sensu-server defaults
update-rc.d sensu-client defaults
update-rc.d sensu-api defaults
update-rc.d sensu-dashboard defaults

/etc/init.d/sensu-server start
/etc/init.d/sensu-client start
/etc/init.d/sensu-api start
/etc/init.d/sensu-dashboard start

echo "Sensu dashboard... http://admin:secret@192.168.0.104:8081/"
