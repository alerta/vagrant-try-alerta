DEBIAN_FRONTEND=noninteractive apt-get -y install postgresql postgresql-contrib libpq-dev

su - postgres -c 'createuser www-data'
su - postgres -c 'createdb monitoring'

cat >>/etc/environment <<EOF
DATABASE_URL=postgres:///monitoring
EOF
