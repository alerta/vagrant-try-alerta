#!/bin/sh -e

set -x

apt-get -y update
apt-get -y install language-pack-en
apt-get -y install git curl wget
apt-get -y install python-stdeb devscripts
