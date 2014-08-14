#!/bin/sh -e

set -x

apt-get -y update
apt-get -y install language-pack-en git curl wget python-stdeb devscripts
