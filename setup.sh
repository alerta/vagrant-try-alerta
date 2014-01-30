#!/bin/sh -e

GIT_REPO=alerta/vagrant-try-alerta

# Update packages
sudo apt-get update

# Install required dependencies
sudo apt-get install -y git wget python-setuptools python-pip build-essential python-dev
sudo apt-get install -y mongodb-server rabbitmq-server apache2 libapache2-mod-wsgi

# Configure MongoDB
grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | sudo tee -a /etc/mongodb.conf
service mongodb restart

# Configure RabbitMQ
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp
sudo service rabbitmq-server restart
wget -qO /var/tmp/rabbitmqadmin http://guest:guest@localhost:55672/cli/rabbitmqadmin && chmod +x /var/tmp/rabbitmqadmin
/var/tmp/rabbitmqadmin declare exchange name=alerts type=fanout

# Install and configure Alerta
sudo pip install alerta
mkdir -p /etc/alerta
cp /vagrant/files/alerta.conf /etc/alerta/alerta.conf
cp /vagrant/files/upstart-alerta.conf /etc/init/alerta.conf
initctl reload-configuration alerta
service alerta restart

# Configure Apache web server
mkdir -p /var/www/alerta
cp /vagrant/files/alerta-api.wsgi /var/www/alerta/alerta-api.wsgi
cp /vagrant/files/httpd-alerta-api.conf /etc/apache2/conf.d/alerta-api.conf
cp /vagrant/files/alerta-dashboard.wsgi /var/www/alerta/alerta-dashboard.wsgi
cp /vagrant/files/httpd-alerta-dashboard.conf /etc/apache2/conf.d/alerta-dashboard.conf
PYTHON_ROOT_DIR=`pip show alerta | awk '/Location/ { print $2 } '`
sed -i "s#@STATIC@#$PYTHON_ROOT_DIR#" /etc/apache2/conf.d/alerta-dashboard.conf
chmod 0775 /var/log/alerta && chgrp www-data /var/log/alerta
service apache2 restart

# Generate test alerts
cp /vagrant/files/create-alerts.sh /var/tmp/create-alerts.sh
chmod +x /var/tmp/create-alerts.sh && /var/tmp/create-alerts.sh

pip show alerta

echo "Alerta Console:  http://192.168.33.15/alerta/dashboard/v2/index.html"
echo "Alerta API URL:  http://192.168.33.15:8080/alerta/api/v2"
echo "Alerta Mgmt URL: http://192.168.33.15:8080/alerta/management"
