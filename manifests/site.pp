
exec { 'apt-update':
    command => '/usr/bin/apt-get update',
}
Exec["apt-update"] -> Package <| |>

### Alerta

package { 'git': }

exec { 'alerta-git-clone':
	command => '/usr/bin/git clone https://github.com/guardian/alerta.git',
	cwd     => '/var/tmp',
	creates => '/var/tmp/alerta',
	require => Package['git'],
}

package { 'python-setuptools': }
package { 'python-pip': }

exec { 'alerta-install-requirements':
	command => '/usr/bin/pip install -r requirements.txt',
	cwd     => '/var/tmp/alerta',
	unless  => '/usr/bin/pip freeze | grep pymongo',
	require => Exec['alerta-git-clone'],
}

exec { 'alerta-install-core':
	command => '/usr/bin/python setup.py install',
	cwd     => '/var/tmp/alerta',
	creates => '/usr/local/bin/alerta',
	require => Exec['alerta-install-requirements'],
}

package { 'mongodb-server': }

package { 'rabbitmq-server': }

exec { 'rabbitmq-mgmt':
	command => '/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_management',
	require => Package['rabbitmq-server'],
}

exec { 'rabbitmq-stomp':
	command => '/usr/lib/rabbitmq/bin/rabbitmq-plugins enable rabbitmq_stomp',
	require => Package['rabbitmq-server'],
}

exec { 'rabbitmq-restart':
	command => '/usr/bin/service rabbitmq-server restart',
	require => [ Exec['rabbitmq-mgmt'], Exec['rabbitmq-stomp'] ],
}

exec { 'rabbitmq-admin':
	command => '/usr/bin/wget http://guest:guest@localhost:55672/cli/rabbitmqadmin && chmod +x rabbitmqadmin',
	cwd     => '/usr/local/bin',
	require => Exec['rabbitmq-restart'],
}

exec { 'rabbitmq-exchange':
	command => '/usr/local/bin/rabbitmqadmin declare exchange name=alerts type=fanout',
	require => Exec['rabbitmq-admin'],

}

package { 'apache2': }
package { 'libapache2-mod-wsgi':
	require => Package['apache2'],
}

file { '/etc/apache2/conf.d/alerta-api.conf':
	source  => '/vagrant/files/httpd-alerta-api.conf',
	require => Package['apache2'],
}

file { '/etc/apache2/conf.d/alerta-dashboard.conf':
	source  => '/vagrant/files/httpd-alerta-dashboard.conf',
	require => Package['apache2'],
}

user { 'alerta': }
group { 'alerta': }

file { '/var/www/alerta':
	ensure  => directory,
	require => Package['apache2'],
}

file { '/var/www/alerta/alerta-api.wsgi':
	source  => '/vagrant/files/alerta-api.wsgi',
	require => [ File['/var/www/alerta'], Package['libapache2-mod-wsgi'] ],
}

file { '/var/www/alerta/alerta-dashboard.wsgi':
	source  => '/vagrant/files/alerta-dashboard.wsgi',
	require => [ File['/var/www/alerta'], Package['libapache2-mod-wsgi'] ],
}

service { 'apache2':
	subscribe => [ File['/etc/apache2/conf.d/alerta-api.conf'], File['/etc/apache2/conf.d/alerta-dashboard.conf'] ],
	require   => [ File['/var/www/alerta/alerta-api.wsgi'], File['/var/www/alerta/alerta-dashboard.wsgi'] ],
}

file { '/etc/alerta':
	ensure => directory,
}

file { '/etc/alerta/alerta.conf':
	source => '/vagrant/files/alerta.conf',
}

file { '/var/log/alerta':
	ensure => directory,
	group  => 'www-data',
	mode   => 0775,
}

file { '/etc/rsyslog.d/alerta.conf':
	content => '*.* @localhost:514',
}

service { 'rsyslog':
	subscribe => File['/etc/rsyslog.d/alerta.conf'],
}

file { '/etc/init/alerta.conf':
	source => '/vagrant/files/upstart-alerta.conf',
	owner  => root,
	group  => root,
}

file { '/etc/init.d/alerta':
	ensure => link,
	target => '/lib/init/upstart-job',
}

service { 'alerta':
	ensure   => running,
	provider => upstart,
	require  => File['/etc/init.d/alerta'],
}

file { '/etc/init/alert-syslog.conf':
	source => '/vagrant/files/upstart-alert-syslog.conf',
	owner  => root,
	group  => root,
}

file { '/etc/init.d/alert-syslog':
	ensure => link,
	target => '/lib/init/upstart-job',
}

service { 'alert-syslog':
	ensure => running,
	provider => upstart,
	require  => File['/etc/init.d/alert-syslog'],
}

package { 'snmpd': }

file { '/etc/default/snmpd':
	content => 'TRAPDRUN=yes',
	owner  => root,
	group  => root,
	require => Package['snmpd'],
}

file { '/etc/snmp/snmptrapd.conf':
	source => '/vagrant/files/snmptrapd.conf',
	owner  => root,
	group  => root,
	require => Package['snmpd'],
}

service { 'snmpd':
	subscribe => [ File['/etc/default/snmpd'], File['/etc/snmp/snmptrapd.conf'] ],
}

### Riemann

$riemann_version = '0.2.2'

exec { 'download-riemann-core':
	command => "/usr/bin/wget http://aphyr.com/riemann/riemann_${riemann_version}_all.deb",
	cwd     => '/var/tmp',
	creates => "/var/tmp/riemann_${riemann_version}_all.deb",
}

package { 'riemann':
	provider => dpkg,
	ensure   => latest,
	source   => "/var/tmp/riemann_${riemann_version}_all.deb",
}

package { 'default-jre': }

file { 'riemann.config':
	name    => '/etc/riemann/riemann.config',
	source  => '/vagrant/files/riemann.config',
	owner   => riemann,
	require => Package['riemann'],
}

file { 'alerta.clj':
	name   => '/etc/riemann/alerta.clj',
	source => '/vagrant/files/alerta.clj',
	owner  => riemann,
}

service { 'riemann':
	ensure  => running,
	require => File['riemann.config'],
}

### Ruby 1.8 (System Version)

package { ['make', 'g++', 'ruby1.8-dev', 'ruby1.8', 'ri1.8', 'rdoc1.8', 'irb1.8']: }
package { ['libreadline-ruby1.8', 'libruby1.8', 'libopenssl-ruby']: }
package { ['libxslt-dev', 'libxml2-dev']: }

package { 'nokogiri':
	ensure   => '1.5.9',
	provider => gem,
	require  => [Package['libxslt-dev'], Package['libxml2-dev']],
}

### Riemann Tools

package { 'riemann-tools':
	provider => gem,
	require  => Package['nokogiri'],
}

package { 'riemann-dash':
	provider => gem,
	require  => Package['nokogiri'],
}

file { '/etc/riemann/config.rb':
	content => 'set :bind, "0.0.0.0"'
}

# service { 'riemann-dash': }
# service { 'riemann-health': }

