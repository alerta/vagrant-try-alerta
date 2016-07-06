# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # config.vm.box = "precise64"  # 12.04
  # config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

  # config.vm.box = "raring64"  # 13.04
  # config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.box = "trusty64"  # 14.04
  config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  # config.vm.box = "wily64"  # 15.10
  # config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/wily/current/wily-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.define "alerta", primary: true do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.100"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
  end

  config.vm.define "alerta-centos", primary: true do |centos7|
    centos7.vm.box = "centos71"
    centos7.vm.box_url = "https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.1/vagrant-centos-7.1.box"
    centos7.vm.network :private_network, ip: "192.168.0.110"
    centos7.vm.provision :shell, :path => "scripts/centos/base.sh"
    centos7.vm.provision :shell, :path => "scripts/centos/alerta.sh"
  end

  config.vm.define "alerta-nagios3" do |nagios3|
    nagios3.vm.network :private_network, ip: "192.168.0.101"
    nagios3.vm.provision :shell, :path => "scripts/base.sh"
    nagios3.vm.provision :shell, :path => "scripts/alerta.sh"
    nagios3.vm.provision :shell, :path => "scripts/nagios3.sh"
  end

  config.vm.define "alerta-zabbix2" do |zabbix2|
    zabbix2.vm.network :private_network, ip: "192.168.0.102"
    zabbix2.vm.provision :shell, :path => "scripts/base.sh"
    zabbix2.vm.provision :shell, :path => "scripts/alerta.sh"
    zabbix2.vm.provision :shell, :path => "scripts/zabbix2.sh"
  end

  config.vm.define "alerta-riemann" do |riemann|
    riemann.vm.network :private_network, ip: "192.168.0.103"
    riemann.vm.provision :shell, :path => "scripts/base.sh"
    riemann.vm.provision :shell, :path => "scripts/alerta.sh"
    riemann.vm.provision :shell, :path => "scripts/riemann.sh"
  end

  config.vm.define "alerta-sensu" do |sensu|
    sensu.vm.network :private_network, ip: "192.168.0.104"
    sensu.vm.provision :shell, :path => "scripts/base.sh"
    sensu.vm.provision :shell, :path => "scripts/alerta.sh"
    sensu.vm.provision :shell, :path => "scripts/sensu.sh"
  end

  config.vm.define "alerta-kibana" do |kibana|
    kibana.vm.network :private_network, ip: "192.168.0.105"
    kibana.vm.provision :shell, :path => "scripts/base.sh"
    kibana.vm.provision :shell, :path => "scripts/alerta.sh"
    kibana.vm.provision :shell, :path => "scripts/kibana.sh"
  end

  config.vm.define "alerta-nagios4" do |nagios4|
    nagios4.vm.network :private_network, ip: "192.168.0.106"
    nagios4.vm.provision :shell, :path => "scripts/base.sh"
    nagios4.vm.provision :shell, :path => "scripts/alerta.sh"
    nagios4.vm.provision :shell, :path => "scripts/nagios4.sh"
  end

  config.vm.define "alerta-kapacitor" do |kapacitor|
    kapacitor.vm.network :private_network, ip: "192.168.0.107"
    kapacitor.vm.provision :shell, :path => "scripts/base.sh"
    kapacitor.vm.provision :shell, :path => "scripts/alerta.sh"
    kapacitor.vm.provision :shell, :path => "scripts/kapacitor.sh"
  end

  config.vm.define "alerta-uwsgi" do |uwsgi|
    uwsgi.vm.network :private_network, ip: "192.168.0.108"
    uwsgi.vm.provision :shell, :path => "scripts/base.sh"
    uwsgi.vm.provision :shell, :path => "scripts/uwsgi.sh"
  end

  config.vm.define "alerta-kibana4" do |kibana4|
    kibana4.vm.network :private_network, ip: "192.168.0.109"
    kibana4.vm.provision :shell, :path => "scripts/base.sh"
    kibana4.vm.provision :shell, :path => "scripts/alerta.sh"
    kibana4.vm.provision :shell, :path => "scripts/kibana4.sh"
  end

  config.vm.define "alerta-zabbix3" do |zabbix3|
    zabbix3.vm.network :private_network, ip: "192.168.0.110"
    zabbix3.vm.provision :shell, :path => "scripts/base.sh"
    zabbix3.vm.provision :shell, :path => "scripts/alerta.sh"
    zabbix3.vm.provision :shell, :path => "scripts/zabbix3.sh"
  end

end
