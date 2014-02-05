#!/bin/sh -e

# Install required dependencies
sudo apt-get -y install python-setuptools python-pip build-essential python-dev
sudo apt-get -y install mongodb-server rabbitmq-server apache2 libapache2-mod-wsgi

# Configure MongoDB
grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | sudo tee -a /etc/mongodb.conf
sudo service mongodb restart

# Configure RabbitMQ
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
sudo /usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp
sudo service rabbitmq-server restart
wget -qO /var/tmp/rabbitmqadmin http://guest:guest@localhost:55672/cli/rabbitmqadmin && chmod +x /var/tmp/rabbitmqadmin
/var/tmp/rabbitmqadmin declare exchange name=alerts type=fanout durable=true

# Install and configure Alerta
sudo pip install alerta
sudo mkdir -p /etc/alerta
sudo cp /vagrant/files/alerta.conf /etc/alerta/alerta.conf
sudo cp /vagrant/files/upstart-alerta.conf /etc/init/alerta.conf
sudo initctl reload-configuration alerta
sudo service alerta restart

# Configure Apache web server
sudo mkdir -p /var/www/alerta
sudo cp /vagrant/files/alerta-api.wsgi /var/www/alerta/alerta-api.wsgi
sudo cp /vagrant/files/httpd-alerta-api.conf /etc/apache2/conf.d/alerta-api.conf
sudo cp /vagrant/files/alerta-dashboard.wsgi /var/www/alerta/alerta-dashboard.wsgi
sudo cp /vagrant/files/httpd-alerta-dashboard.conf /etc/apache2/conf.d/alerta-dashboard.conf
PYTHON_ROOT_DIR=`pip show alerta | awk '/Location/ { print $2 } '`
sudo sed -i "s#@STATIC@#$PYTHON_ROOT_DIR#" /etc/apache2/conf.d/alerta-dashboard.conf
sudo chmod 0777 /var/log/alerta && sudo chgrp www-data /var/log/alerta
sudo service apache2 restart

# Generate test alerts
cp /vagrant/files/create-alerts.sh /var/tmp/create-alerts.sh
chmod +x /var/tmp/create-alerts.sh && /var/tmp/create-alerts.sh

# Clean-up
mongo monitoring --eval 'db.heartbeats.remove()'

pip show alerta
