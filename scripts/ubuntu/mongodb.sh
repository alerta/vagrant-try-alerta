DEBIAN_FRONTEND=noninteractive apt-get -y install mongodb-server

grep -q smallfiles /etc/mongodb.conf || echo "smallfiles = true" | tee -a /etc/mongodb.conf
service mongodb restart

cat >>/etc/environment <<EOF
DATABASE_URL=mongodb://localhost:27017/monitoring
EOF
