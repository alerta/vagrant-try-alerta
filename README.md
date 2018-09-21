Try Alerta using Vagrant
========================

To run Alerta in a [vagrant](https://www.vagrantup.com/) virtual machine run:

```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up alerta
```

To run Nagios and Alerta in the same virtual machine run:
```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up alerta-nagios3
$ vagrant ssh alerta-nagios3
```

To run Zabbix and Alerta in the same virtual machine run:
```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up alerta-zabbix
$ vagrant ssh alerta-zabbix
```

To run Riemann and Alerta in the same virtual machine run:
```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up alerta-riemann
$ vagrant ssh alerta-riemann
```

To run Sensu and Alerta in the same virtual machine run:
```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up alerta-sensu
$ vagrant ssh alerta-sensu
```

To run ELK stack (ie. Logstash & Kibana) and Alerta in the same virtual machine run:
```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up alerta-kibana
$ vagrant ssh alerta-kibana
```

To use the command-line tools on the Alerta-Nagios3 vagrant box, for example, run:

```
$ vagrant ssh alerta
$ alerta send -r web01 -e NodeDown -s major -S Web -E Production -t "Server down."
$ alerta query
```

Each vagrant box is configured to use a different IP address:

| VM Image                        | VirtalBox ID     | URL                   |
|---------------------------------|------------------|-----------------------|
| Alerta on Ubuntu/MongoDB/Apache)  | alerta           | http://192.168.0.100  |
| Alerta " Postgres/Apache) | alerta-postgres  | http://192.168.0.101  |
| Alerta " Postgres/Nginx)  | alerta-nginx     | http://192.168.0.102  |
| Alerta on Centos7  | alerta-centos    | 192.168.0.110 |                            |
| Alerta on OpenSuse | alerta-opensuse  | 192.168.0.121 |                            |

| Alerta & Nagios3   | alerta-nagios3   | 192.168.0.101 |                            |
| Alerta & Zabbix    | alerta-zabbix2   | 192.168.0.102 |                            |
| Alerta & Riemann   | alerta-riemann   | 192.168.0.103 |                            |
| Alerta & Sensu     | alerta-sensu     | 192.168.0.104 |                            |
| Alerta & Kibana3   | alerta-kibana    | 192.168.0.105 |                            |
| Alerta & Nagios4   | alerta-nagios4   | 192.168.0.106 |                            |
| Alerta & kapacitor | alerta-kapacitor | 192.168.0.107 |                            |
| Alerta & Kibana4   | alerta-kibana4   | 192.168.0.109 |                            |
| Alerta & Zabbix3   | alerta-zabbix3   | 192.168.0.111 |                            |
| Alerta & Kibana5   | alerta-kibana5   | 192.168.0.112 |                            |
| Alerta & Grafana   | alerta-grafana   | 192.168.0.122 | http://192.168.0.121:3000/ |

To use the web-based console for the Alerta Riemann vagrant box, for example:

http://192.168.0.103/

To access the API:

http://192.168.0.103:8080/api

To view the application management web pages:

http://192.168.0.103:8080/management

License
-------

Copyright (c) 2013-2018 Nick Satterly. Available under the MIT License.
