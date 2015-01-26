Try Alerta using Vagrant
========================

To run Alerta in a virtual machine run:

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

| VM Image         | IP Address    |
| ---------------- | --------------|
| Alerta only      | 192.168.0.100 |
| Alerta & Nagios3 | 192.168.0.101 |
| Alerta & Zabbix  | 192.168.0.102 |
| Alerta & Riemann | 192.168.0.103 |
| Alerta & Sensu   | 192.168.0.104 |
| Alerta & Kibana  | 192.168.0.105 |

To use the web-based console for the Alerta Riemann vagrant box, for example:

http://192.168.0.103/

To access the API:

http://192.168.0.103:8080/api

To view the application management web pages:

http://192.168.0.103:8080/management

License
-------

Copyright (c) 2013 Nick Satterly. Available under the MIT License.
