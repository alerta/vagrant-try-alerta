Try Alerta
==========

To run Riemann and Alerta in a virtual machine run:

```
$ git clone https://github.com/alerta/try-alerta.git
$ cd try-alerta
$ vagrant up
```

To use the command-line tool:

```
$ vagrant ssh
$ alert-query
```

To use the web-based console:

```
http://192.168.33.11:8000/alerta/dashboard/v2/index.html
```

License
-------

Copyright (c) 2013 Nick Satterly. Available under the MIT License.
