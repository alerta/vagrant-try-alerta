#!/bin/sh -ex

GIT_REPO=alerta/vagrant-try-alerta

# Update packages
sudo apt-get update

# Install required dependencies
sudo apt-get install -y git wget python-setuptools python-pip
sudo apt-get install -y build-essential python-dev

# Install and configure MongoDB
sudo apt-get install -y mongodb-server
echo "smallfiles = true" | sudo tee -a /etc/mongodb.conf
service mongodb restart

# Install and configure RabbitMQ
sudo apt-get install -y rabbitmq-server
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp
sudo service rabbitmq-server restart
cd /var/tmp
wget http://guest:guest@localhost:55672/cli/rabbitmqadmin && chmod +x rabbitmqadmin
./rabbitmqadmin declare exchange name=alerts type=fanout

# Install and configure Alerta
sudo pip install alerta
mkdir -p /etc/alerta
wget -O /etc/alerta/alerta.conf https://raw.github.com/${GIT_REPO}/master/files/alerta.conf
wget -O /etc/init/alerta.conf https://raw.github.com/${GIT_REPO}/master/files/upstart-alerta.conf
initctl reload-configuration alerta

# Install and configure Apache web server
sudo apt-get install -y apache2 libapache2-mod-wsgi
mkdir -p /var/www/alerta
wget -O /var/www/alerta/alerta-api.wsgi https://raw.github.com/${GIT_REPO}/master/files/alerta-api.wsgi
wget -O /etc/apache2/conf.d/alerta-api.conf https://raw.github.com/${GIT_REPO}/master/files/httpd-alerta-api.conf
wget -O /var/www/alerta/alerta-dashboard.wsgi https://raw.github.com/${GIT_REPO}/master/files/alerta-dashboard.wsgi
wget -O /etc/apache2/conf.d/alerta-dashboard.conf https://raw.github.com/${GIT_REPO}/master/files/httpd-alerta-dashboard.conf
chgrp www-data /var/log/alerta
apachectl graceful

