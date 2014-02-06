#!/bin/sh -e

set -x

# Install required dependencies
apt-get -y install python-setuptools python-pip build-essential python-dev
apt-get -y install mongodb-server rabbitmq-server apache2 libapache2-mod-wsgi

# Configure MongoDB
grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | tee -a /etc/mongodb.conf
service mongodb restart

# Configure RabbitMQ
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp
service rabbitmq-server restart
wget -qO /var/tmp/rabbitmqadmin http://guest:guest@localhost:55672/cli/rabbitmqadmin && chmod +x /var/tmp/rabbitmqadmin
/var/tmp/rabbitmqadmin declare exchange name=alerts type=fanout durable=true

# Install and configure Alerta
pip install alerta
mkdir -p /etc/alerta
cp /vagrant/files/alerta.conf /etc/alerta/alerta.conf
cp /vagrant/files/upstart-alerta.conf /etc/init/alerta.conf
initctl reload-configuration alerta
service alerta restart

# Configure Apache web server
mkdir -p /var/www/alerta
cp /vagrant/files/alerta-api.wsgi /var/www/alerta/alerta-api.wsgi
cp /vagrant/files/httpd-alerta-api.conf /etc/apache2/sites-available/alerta-api
a2ensite alerta-api

cp /vagrant/files/alerta-dashboard.wsgi /var/www/alerta/alerta-dashboard.wsgi
cp /vagrant/files/httpd-alerta-dashboard.conf /etc/apache2/sites-available/alerta-dashboard
PYTHON_ROOT_DIR=`python -c "import alerta; print(alerta.__dict__['__path__'][0])"`
sed -i "s#@STATIC@#$PYTHON_ROOT_DIR#" /etc/apache2/sites-available/alerta-dashboard
a2ensite alerta-dashboard

chmod 0777 /var/log/alerta && chgrp www-data /var/log/alerta
a2dissite 000-default
echo "ServerName localhost" >> /etc/apache2/apache2.conf
service apache2 reload

# Generate test alerts
cp /vagrant/files/create-alerts.sh /var/tmp/create-alerts.sh
chmod +x /var/tmp/create-alerts.sh && /var/tmp/create-alerts.sh

# Clean-up
mongo monitoring --eval 'db.heartbeats.remove()'
