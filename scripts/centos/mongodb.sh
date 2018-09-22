
cat >/etc/yum.repos.d/mongodb-org.repo <<EOF
[mongodb-org-4.0]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/4.0/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.0.asc
EOF

yum -y install mongodb-org

systemctl start mongod
systemctl enable mongod

cat >>/etc/environment <<EOF
DATABASE_URL=mongodb://localhost:27017/monitoring
EOF
