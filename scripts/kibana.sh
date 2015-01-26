#!/bin/sh -e

set -x

DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-7-jre-headless
wget -qO logstash.deb https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb && dpkg -i logstash.deb
wget -qO logstash-contrib.deb https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb && dpkg -i logstash-contrib.deb
wget -qO elasticsearch.deb https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.deb && dpkg -i elasticsearch.deb

/usr/share/elasticsearch/bin/plugin --install mobz/elasticsearch-head
cat >>/etc/elasticsearch/elasticsearch.yml << EOF
http.cors.enabled: true
http.cors.allow-origin: http://192.168.0.105
EOF
service elasticsearch start

cd /var/www
wget -qO- http://download.elasticsearch.org/kibana/kibana/kibana-latest.tar.gz | tar zxf -
mv /var/www/kibana-latest/ /var/www/html/kibana/

cat >/etc/logstash/conf.d/alerta.conf << EOF
input {
    tcp {
        port  => 1514
        codec => json_lines
    }
}
output {
    # stdout {}
    elasticsearch {
        protocol => "http"
        host     => "localhost"
    }
}
EOF
start logstash

cat >>/etc/alertad.conf << EOF
PLUGINS = ['reject','logstash']
LOGSTASH_HOST = 'localhost'
LOGSTASH_PORT = 1514
EOF
apachectl restart

echo "Alerta URL:  http://192.168.0.105/"
echo "Kibana URL:  http://192.168.0.105/kibana/#/dashboard/file/logstash.json"
echo "ES Head URL: http://192.168.0.105:9200/_plugin/head/"

