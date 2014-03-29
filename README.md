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

To use the command-line tools on the Alerta-Nagios3 vagrant box, for example, run:

```
$ vagrant ssh alerta-nagios3 -- -A
$ alert-query
$ alert-sender
```

Each vagrant box is configured to use a different IP address:

| VM Image       | IP Address    |
| -------------- | --------------|
| Alerta only    | 192.168.0.100 |
| Alerta Nagios3 | 192.168.0.101 |
| Alerta Zabbix  | 192.168.0.102 |
| Alerta Riemann | 192.168.0.103 |

To use the web-based console for the Alerta Riemann vagrant box, for example:

http://192.168.0.103/alerta/dashboard/v2/index.html

To access the API:

http://192.168.0.103:8080/alerta/api/v2

To view the application management web pages:

http://192.168.0.103:8080/alerta/management

License
-------

Copyright (c) 2013 Nick Satterly. Available under the MIT License.
