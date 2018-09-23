#!/usr/bin/env bash

zypper --non-interactive install mongodb-server

# disable mongodb authentication for development environment
sed -i 's/authorization: enabled/authorization: disabled/' /etc/mongodb.conf

systemctl restart mongodb
systemctl enable mongodb

cat >>/etc/environment <<EOF
DATABASE_URL=mongodb://localhost:27017/monitoring
EOF
