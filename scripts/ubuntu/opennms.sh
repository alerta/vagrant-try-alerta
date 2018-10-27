echo "127.0.0.1 server.opennms.local server" >>/etc/hosts

echo "server.opennms.local" >/etc/hostname

cat >/etc/postgresql/9.5/main/pg_hba.conf <<EOF

local   all         all                                          trust
host    all         all         127.0.0.1/32                     trust
host    all         all         ::1/128                          trust
EOF

systemctl restart postgresql
systemctl enable postgresql

echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

add-apt-repository ppa:webupd8team/java
apt-get update -y
apt-get install oracle-java7-installer -y

java -version

cat >/etc/apt/sources.list.d/opennms.list <<EOF
deb http://debian.opennms.org stable main
deb-src http://debian.opennms.org stable main
EOF

wget -O - http://debian.opennms.org/OPENNMS-GPG-KEY | sudo apt-key add -

debconf-set-selections <<< "postfix postfix/main_mailer_type select Local only"
debconf-set-selections <<< "postfix postfix/mailname string $HOSTNAME"

apt-get update -y
SKIP_IPLIKE_INSTALL=1 apt-get install default-mta opennms -y

/usr/share/opennms/bin/install -dis

systemctl start opennms

ufw --force enable
ufw allow 8980
ufw status

echo "http://192.168.0.121:8980/opennms"
echo "admin/admin"
