#!/bin/sh -e

echo “postfix postfix/main_mailer_type select No configuration” | sudo debconf-set-selections
echo “nagios3-cgi nagios3/adminpassword password nagiosadmin” | sudo debconf-set-selections
echo “nagios3-cgi nagios3/adminpassword-repeat password nagiosadmin” | sudo debconf-set-selections
sudo apt-get -y install nagios3 nagios-nrpe-plugin


