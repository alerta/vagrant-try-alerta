#!/bin/sh -e

set -x

curl https://packagecloud.io/gpg.key | sudo apt-key add -
echo "deb https://packagecloud.io/grafana/stable/debian/ stretch main" | tee /etc/apt/sources.list.d/grafana.list
apt-get update

apt-get install -y grafana

systemctl daemon-reload
systemctl start grafana-server
systemctl status grafana-server

systemctl enable grafana-server.service
