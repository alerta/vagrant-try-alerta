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
alerta/bin/pip install alerta-app

# Configure Alerta API
wget -qO /etc/apache2/sites-available/alerta https://raw.githubusercontent.com/guardian/alerta/master/etc/httpd-alerta.conf
mkdir -p /opt/alerta/apache
wget -qO /opt/alerta/apache/app.wsgi https://raw.githubusercontent.com/guardian/alerta/master/alerta/app/app.wsgi
a2ensite alerta

# Configure Apache
echo "ServerName localhost" >> /etc/apache2/apache2.conf
service apache2 reload

# Configure Alerta Dashboard
cd /var/www
rm -Rf alerta*
curl -L https://github.com/alerta/angular-alerta-webui/tarball/master | tar xz
mv alerta-angular-alerta-webui-*/app/ alerta

# Generate test alerts
wget -qO - /var/tmp/create-alerts.sh https://raw.githubusercontent.com/guardian/alerta/master/contrib/examples/create-new-alert.sh | sh

