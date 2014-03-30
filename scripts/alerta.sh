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

# Configure Apache web server
wget -qO /etc/apache2/sites-available/alerta https://raw.githubusercontent.com/guardian/alerta/master/etc/httpd-alerta.conf
mkdir /opt/alerta/apache
wget -qO /opt/alerta/apache/app.wsgi https://raw.githubusercontent.com/guardian/alerta/master/alerta/app/app.wsgi
a2ensite alerta

#cp /vagrant/files/alerta-dashboard.wsgi /var/www/alerta/alerta-dashboard.wsgi
#cp /vagrant/files/httpd-alerta-dashboard.conf /etc/apache2/sites-available/alerta-dashboard
#PYTHON_ROOT_DIR=`python -c "import alerta; print(alerta.__dict__['__path__'][0])"`
#sed -i "s#@STATIC@#$PYTHON_ROOT_DIR#" /etc/apache2/sites-available/alerta-dashboard
#a2ensite alerta-dashboard

a2dissite 000-default
echo "ServerName localhost" >> /etc/apache2/apache2.conf
apachectl restart

# Generate test alerts
wget -qO - /var/tmp/create-alerts.sh https://raw.githubusercontent.com/guardian/alerta/master/contrib/examples/create-new-alert.sh | sh

# Clean-up
mongo monitoring --eval 'db.heartbeats.remove()'
