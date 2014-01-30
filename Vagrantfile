# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "raring"
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.network :private_network, ip: "192.168.33.15"

  config.vm.network :forwarded_port, guest: 80, host: 8000      # alerta-dashboard
  config.vm.network :forwarded_port, guest: 8080, host: 8080    # alerta-api
  config.vm.network :forwarded_port, guest: 15672, host: 15672  # rabbitmq-mgmt 3.x
  config.vm.network :forwarded_port, guest: 55672, host: 55672  # rabbitmq-mgmt 2.x

  config.vm.provision :shell, :path => "setup.sh"

end
