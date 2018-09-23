#!/bin/sh -ex

wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb http://packages.elastic.co/elasticsearch/2.x/debian stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list
echo "deb http://packages.elastic.co/logstash/2.3/debian stable main" > /etc/apt/sources.list.d/logstash-2.x.list
apt-get -y update
apt-get -y upgrade

apt-get -y install ruby ruby-dev logstash openjdk-8-jre-headless openjdk-8-jdk elasticsearch
update-ca-certificates -f

/usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head
cat >>/etc/elasticsearch/elasticsearch.yml <<EOF
cluster.name: alerta
EOF
service elasticsearch start

wget -O /tmp/kibana-latest.tar.gz https://download.elastic.co/kibana/kibana/kibana-4.5.0-linux-x64.tar.gz
tar zxf /tmp/kibana-latest.tar.gz -C /opt
mv /opt/kibana-* /opt/kibana

/opt/kibana4/bin/kibana serve -l /var/log/kibana4.log &

wget -qO /etc/logstash/conf.d/logstash.conf https://raw.githubusercontent.com/alerta/kibana-alerta/master/logstash.conf
service logstash start

cat >>/etc/alertad.conf <<EOF
PLUGINS = ['reject','logstash']
LOGSTASH_HOST = 'localhost'
LOGSTASH_PORT = 1514
EOF
apachectl restart
