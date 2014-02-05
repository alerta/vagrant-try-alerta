Try Alerta using Vagrant
========================

To run Alerta in a virtual machine run:

```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up
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

To use the command-line tools:

```
$ alert-query
$ alert-sender
```

| Alerta only | 192.168.0.103 |
| Alerta Nagios3 | 192.168.0.103 |
| Alerta Zabbix | 192.168.0.103 |
| Alerta Riemann | 192.168.0.103 |

To use the web-based console:

http://<ip_address>/alerta/dashboard/v2/index.html

To access the API:

http://<ip_address>:8080/alerta/api/v2

To view the application management web pages:

http://<ip_address>:8080/alerta/management

License
-------

Copyright (c) 2013 Nick Satterly. Available under the MIT License.
