#!/bin/sh -e

set -x

DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-7-jre-headless
wget -qO logstash.deb https://download.elastic.co/logstash/logstash/packages/debian/logstash_2.0.0-1_all.deb && dpkg -i logstash.deb
wget -qO elasticsearch.deb https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.0.0/elasticsearch-2.0.0.deb && dpkg -i elasticsearch.deb

/usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head
cat >>/etc/elasticsearch/elasticsearch.yml << EOF
cluster.name: alerta
EOF
service elasticsearch start

cd /opt
wget -qO- https://download.elastic.co/kibana/kibana/kibana-4.2.0-linux-x64.tar.gz | tar zxvf -
ln -s kibana-* kibana4
/opt/kibana4/bin/kibana serve -l /var/log/kibana4.log &

wget -qO /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/alerta/kibana-alerta/master/logstash.conf
service logstash start

cat >>/etc/alertad.conf << EOF
PLUGINS = ['reject','logstash']
LOGSTASH_HOST = 'localhost'
LOGSTASH_PORT = 1514
EOF
apachectl restart

echo "Alerta URL:  http://192.168.0.105/"
echo "Kibana URL:  http://192.168.0.105:5601/"
echo "ES Head URL: http://192.168.0.105:9200/_plugin/head/"
