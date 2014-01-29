#!/bin/sh -ex

GIT_REPO=alerta/vagrant-try-alerta

# Update packages
sudo apt-get update

# Install required dependencies
sudo apt-get install -y git wget python-setuptools python-pip
sudo apt-get install -y build-essential python-dev

# Install and configure MongoDB
sudo apt-get install -y mongodb-server
grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | sudo tee -a /etc/mongodb.conf
service mongodb restart

# Install and configure RabbitMQ
sudo apt-get install -y rabbitmq-server
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp
sudo service rabbitmq-server restart
wget -qO /var/tmp/rabbitmqadmin http://guest:guest@localhost:55672/cli/rabbitmqadmin && chmod +x /var/tmp/rabbitmqadmin
/var/tmp/rabbitmqadmin declare exchange name=alerts type=fanout

# Install and configure Alerta
sudo pip install alerta
mkdir -p /etc/alerta
wget -qO /etc/alerta/alerta.conf https://raw.github.com/${GIT_REPO}/master/files/alerta.conf
wget -qO /etc/init/alerta.conf https://raw.github.com/${GIT_REPO}/master/files/upstart-alerta.conf
initctl reload-configuration alerta
service alerta restart

PYTHON_ROOT_DIR=`pip show alerta | awk '/Location/ { print $2 } '`

# Install and configure Apache web server
sudo apt-get install -y apache2 libapache2-mod-wsgi
mkdir -p /var/www/alerta
wget -qO /var/www/alerta/alerta-api.wsgi https://raw.github.com/${GIT_REPO}/master/files/alerta-api.wsgi
wget -qO /etc/apache2/conf.d/alerta-api.conf https://raw.github.com/${GIT_REPO}/master/files/httpd-alerta-api.conf
wget -qO /var/www/alerta/alerta-dashboard.wsgi https://raw.github.com/${GIT_REPO}/master/files/alerta-dashboard.wsgi
wget -qO /etc/apache2/conf.d/alerta-dashboard.conf https://raw.github.com/${GIT_REPO}/master/files/httpd-alerta-dashboard.conf
sed -i "s#@STATIC@#$PYTHON_ROOT_DIR#" /etc/apache2/conf.d/alerta-dashboard.conf
chmod 0775 /var/log/alerta && chgrp www-data /var/log/alerta
apachectl graceful

wget -qO /var/tmp/create-alerts.sh https://raw.github.com/${GIT_REPO}/master/files/create-alerts.sh
chmod +x /var/tmp/create-alerts.sh && /var/tmp/create-alerts.sh

pip show alerta

echo "Alerta Console: http://192.168.33.15/alerta/dashboard/v2/index.html"
echo "Alerta API URL: http://192.168.33.15:8080/alerta/api/v2/alerts"
