DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib

su - postgres -c 'createuser www-data'
su - postgres -c 'createdb monitoring'

cat >/etc/alertad.conf << EOF
DATABASE_URL='postgres:///monitoring'
EOF
