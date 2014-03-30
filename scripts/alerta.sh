#!/bin/sh -e

set -x

# Install required dependencies
apt-get -y install python-setuptools python-pip build-essential python-dev python-virtualenv
apt-get -y install mongodb-server rabbitmq-server apache2 libapache2-mod-wsgi

# Configure MongoDB
grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | tee -a /etc/mongodb.conf
service mongodb restart

# Configure RabbitMQ
/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management
service rabbitmq-server restart

# Install and configure Alerta
id alerta || (groupadd alerta && useradd -g alerta alerta)
cd /opt
virtualenv alerta
alerta/bin/pip install alerta

# Configure Alerta API
wget -qO /etc/apache2/sites-available/alerta https://raw.githubusercontent.com/guardian/alerta/master/etc/httpd-alerta.conf
mkdir -p /opt/alerta/apache
wget -qO /opt/alerta/apache/app.wsgi https://raw.githubusercontent.com/guardian/alerta/master/alerta/app/app.wsgi
a2ensite alerta

# Configure Alerta Dashboard
wget -qO /etc/apache2/sites-available/alerta-dashboard https://raw.githubusercontent.com/guardian/alerta/master/etc/httpd-alerta-dashboard.conf
wget -qO /opt/alerta/apache/dashboard.wsgi https://raw.githubusercontent.com/guardian/alerta/master/alerta/dashboard/dashboard.wsgi
a2ensite alerta-dashboard

# Configure Apache
a2dissite 000-default
echo "ServerName localhost" >> /etc/apache2/apache2.conf
service apache2 reload

# Generate test alerts
wget -qO - /var/tmp/create-alerts.sh https://raw.githubusercontent.com/guardian/alerta/master/contrib/examples/create-new-alert.sh | sh

echo "Dashboard -> http://192.168.0.100/alerta/index.html"
