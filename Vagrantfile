# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # config.vm.box = "precise64"  # 12.04
  # config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box"

  # config.vm.box = "raring64"  # 13.04
  # config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/raring/current/raring-server-cloudimg-amd64-vagrant-disk1.box"

  # config.vm.box = "trusty64"  # 14.04
  # config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  # config.vm.box = "wily64"  # 15.10
  # config.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/wily/current/wily-server-cloudimg-amd64-vagrant-disk1.box"

  # config.vm.box = "xenial64"  # 16.04
  # config.vm.box_url = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box"

  config.vm.box = "bionic64"  # 18.04
  config.vm.box_url = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64-vagrant.box"

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
  end

  config.vm.define "alerta", primary: true do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.100"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/base.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/apache.sh"
  end

  config.vm.define "alerta-postgres", primary: true do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.101"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/base.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/postgres.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/apache.sh"
  end

  config.vm.define "alerta-nginx", primary: true do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.102"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/base.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/postgres.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/ubuntu/nginx.sh"
  end

  config.vm.define "alerta-centos7", primary: true do |alerta|
    #alerta.vm.box = "centos71"
    #alerta.vm.box_url = "https://github.com/CommanderK5/packer-centos-template/releases/download/0.7.1/vagrant-centos-7.1.box"
    alerta.vm.box = "centos/7"
    #alerta.vm.box_url = "https://atlas.hashicorp.com/centos/boxes/7/versions/1704.01/providers/virtualbox.box"
    alerta.vm.network :private_network, ip: "192.168.0.103"
    alerta.vm.provision :shell, :path => "scripts/centos/base.sh"
    alerta.vm.provision :shell, :path => "scripts/centos/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/centos/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/centos/apache.sh"
  end

  config.vm.define "alerta-amzn2", primary: true do |alerta|
    alerta.vm.box = "winky/amazonlinux-2"
    alerta.vm.network :private_network, ip: "192.168.0.104"
    alerta.vm.provision :shell, :path => "scripts/centos/base.sh"
    alerta.vm.provision :shell, :path => "scripts/centos/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/centos/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/centos/apache.sh"
  end

  config.vm.define "alerta-opensuse", primary: true do |alerta|
    alerta.vm.box = "opensuse/openSUSE-Tumbleweed-x86_64"
    alerta.vm.network :private_network, ip: "192.168.0.105"
    alerta.vm.provision :shell, :path => "scripts/opensuse/alerta.sh"
  end

  # ##################################################################

  config.vm.define "alerta-nagios3" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.101"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/nagios3.sh"
  end

  config.vm.define "alerta-nagios4" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.106"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/nagios4.sh"
  end

  config.vm.define "alerta-zabbix2" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.102"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/zabbix2.sh"
  end

  config.vm.define "alerta-zabbix3" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.111"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/zabbix3.sh"
  end

  config.vm.define "alerta-riemann" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.103"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/riemann.sh"
  end

  config.vm.define "alerta-sensu" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.104"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/sensu.sh"
  end

  config.vm.define "alerta-kibana3" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.105"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/kibana.sh"
  end

  config.vm.define "alerta-kibana4" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.109"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/kibana4.sh"
  end

  config.vm.define "alerta-kibana5" do |alerta|
    alerta.vm.provider :virtualbox do |v|
      v.memory = 2048
      v.cpus = 2
    end
    alerta.vm.network :private_network, ip: "192.168.0.112"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/kibana5.sh"
  end

  config.vm.define "alerta-kapacitor" do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.107"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/mongodb.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/kapacitor.sh"
  end

  config.vm.define "alerta-grafana", primary: true do |alerta|
    alerta.vm.network :private_network, ip: "192.168.0.122"
    alerta.vm.provision :shell, :path => "scripts/base.sh"
    alerta.vm.provision :shell, :path => "scripts/postgres.sh"
    alerta.vm.provision :shell, :path => "scripts/alerta.sh"
    alerta.vm.provision :shell, :path => "scripts/grafana.sh"
  end
end
