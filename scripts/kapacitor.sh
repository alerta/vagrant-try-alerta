#!/bin/sh -e

set -x

API_KEY=demo-key

curl -sL https://repos.influxdata.com/influxdb.key | apt-key add -
echo "deb https://repos.influxdata.com/ubuntu xenial stable" | tee /etc/apt/sources.list.d/influxdb.list
apt-get update

echo "Installing Influxdb..."
apt-get install influxdb
systemctl start influxdb

echo "Installing Telegraf..."
apt-get install telegraf
systemctl start telegraf

echo "Installing Kapacitor..."
apt-get install kapacitor

echo "Configuring Kapacitor..."
sed -i s/alerta/alerta-default/ /etc/kapacitor/kapacitor.conf
cat >>/etc/kapacitor/kapacitor.conf << EOF
[alerta]
  enabled = true
  url = "http://localhost:8080"
  token = "$API_KEY"
  environment = "Development"
  origin = "kapacitor/$HOSTNAME"
EOF

cat >/etc/kapacitor/cpu_alert.tick << EOF
stream
    |from()
        .measurement('cpu')
    |alert()
        .id('{{ index .Tags "host" }}')
        .message('{{ .Level}}: {{ .Name }}/{{ index .Tags "name" }} TEMPERATURE ALERT sensor: {{ index .Tags "sensorName"}} = {{ index .Fields "sensorValue" }}')
        .info(lambda: "usage_idle" < 70)
        .warn(lambda: "usage_idle" < 100)
        .alerta()
            .resource('node55')
            .event('cpuHigh')
            .services('{{ index .Tags "customerName" }}')
            .group('Check Point Firewall')
            .value('{{ index .Fields "sensorValue" }}')
        .log('/tmp/cp_temperature_threshold.log')
EOF

systemctl start kapacitor
kapacitor define cpu_alert -tick /etc/kapacitor/cpu_alert.tick -type stream -dbrp telegraf.default

echo "Influxdb  ==> http://192.168.0.107:8086"
echo "Kapacitor ==> http://192.168.0.107:9092"
