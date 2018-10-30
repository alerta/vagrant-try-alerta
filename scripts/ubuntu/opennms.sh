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

pip install git+https://github.com/alerta/alerta-contrib.git#subdirectory=integrations/syslog

cat >/etc/systemd/system/alerta-syslog.service <<EOF
[Unit]
Description=Alerta Syslog Listener
After=network.target

[Service]
ExecStart=/opt/alerta/bin/alerta-syslog
Type=simple

[Install]
WantedBy=default.target
EOF

cat >/etc/opennms/syslog-northbounder-configuration.xml <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<syslog-northbounder-config>
   <!-- The following are set to the default values. -->
   <enabled>true</enabled>
   <nagles-delay>1000</nagles-delay>
   <batch-size>100</batch-size>
   <queue-size>300000</queue-size>
   <!-- <message-format>ALARM ID:${alarmId} NODE:${nodeLabel}; ${logMsg}</message-format> -->
    <!-- You can specify date format within <date-format>, default is ISO 8601 -->
   <message-format>ALARM ID:${alarmId} NODE:${nodeLabel} IP:${ipAddr}
      FIRST:${firstOccurrence} LAST:${lastOccurrence}
      COUNT:${count} UEI:${alarmUei} SEV:${severity}
      x733Type:${x733AlarmType} x733Cause:${x733ProbableCause}
      ${logMsg}
   </message-format>
<!-- More than one destination is supported -->
   <destination>
      <destination-name>localTest</destination-name>
      <host>127.0.0.1</host>
      <port>514</port>
      <ip-protocol>UDP</ip-protocol>
      <facility>LOCAL0</facility>
      <max-message-length>1024</max-message-length>
      <send-local-name>true</send-local-name>
      <send-local-time>true</send-local-time>
      <truncate-message>false</truncate-message>
   </destination>
<!-- Highly recommended, but not required, to only forward a set of Alarm UEIs -->
<!--
   <uei>uei.opennms.org/nodes/nodeDown</uei>
   <uei>uei.opennms.org/nodes/nodeUp</uei>
-->
</syslog-northbounder-config>
EOF

systemctl start alerta-syslog
systemctl start opennms

# ufw --force enable
# ufw allow 8980
# ufw status

echo "http://192.168.0.121:8980/opennms"
echo "admin/admin"
