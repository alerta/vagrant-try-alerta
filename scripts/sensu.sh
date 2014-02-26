#!/bin/sh

# set -x

wget -q http://repos.sensuapp.org/apt/pubkey.gpg -O- | sudo apt-key add -
echo "deb     http://repos.sensuapp.org/apt sensu main" > /etc/apt/sources.list.d/sensu.list
apt-get -y update
apt-get -y install redis-server sensu ruby-dev
gem install sensu-plugin httparty

wget -qO /etc/sensu/config.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.config.json
wget -qO /etc/sensu/conf.d/alerta.json https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.alerta.json
wget -qO /etc/sensu/handlers/alerta.rb https://raw.github.com/alerta/vagrant-try-alerta/master/files/sensu.alerta.rb
chmod +x /etc/sensu/handlers/alerta.rb
wget -O /etc/sensu/plugins/check-procs.rb https://raw.github.com/sensu/sensu-community-plugins/master/plugins/processes/check-procs.rb
chmod 755 /etc/sensu/plugins/check-procs.rb

rabbitmqctl add_vhost /sensu
rabbitmqctl add_user sensu sensu
rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"

echo "LOG_LEVEL=debug" >>/etc/default/sensu

update-rc.d sensu-server defaults
update-rc.d sensu-client defaults
update-rc.d sensu-api defaults
update-rc.d sensu-dashboard defaults

/etc/init.d/sensu-server start
/etc/init.d/sensu-client start
/etc/init.d/sensu-api start
/etc/init.d/sensu-dashboard start

echo "Sensu dashboard... http://admin:secret@192.168.0.104:8081/"
