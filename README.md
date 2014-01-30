Try Alerta using Vagrant
========================

To run Riemann and Alerta in a virtual machine run:

```
$ git clone https://github.com/alerta/vagrant-try-alerta.git
$ cd vagrant-try-alerta
$ vagrant up
```

To use the command-line tool:

```
$ vagrant ssh
$ alert-query
```

To use the web-based console:

http://192.168.33.15/alerta/dashboard/v2/index.html

To access the API:

http://192.168.33.15:8080/alerta/api/v2

To view the application management web pages:

http://192.168.33.15:8080/alerta/management

License
-------

Copyright (c) 2013 Nick Satterly. Available under the MIT License.
