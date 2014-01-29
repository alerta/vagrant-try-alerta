# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "raring"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :private_network, ip: "192.168.33.15"

  config.vm.network :forwarded_port, guest: 80, host: 8000      # alerta-dashboard
  config.vm.network :forwarded_port, guest: 8080, host: 8080    # alerta-api
  config.vm.network :forwarded_port, guest: 55672, host: 55672  # rabbitmq-mgmt
  config.vm.network :forwarded_port, guest: 4567, host: 4567    # riemann-dash
  config.vm.network :forwarded_port, guest: 5556, host: 5556    # riemann-ws

  config.vm.provision :shell, :path => "setup.sh"

end
