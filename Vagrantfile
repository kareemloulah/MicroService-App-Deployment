# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
# Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  # config.vm.box = "base"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network" , ip: "192.168.56.10"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Disable the default share of the current code directory. Doing this
  # provides improved isolation between the vagrant box and your host
  # by making sure your Vagrantfile isn't accessible to the vagrant box.
  # If you use this you may want to enable additional shared subfolders as
  # shown above.
  # config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
# end
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Define number of VMs and their base image
  NUM_INSTANCES = 5
  INSTANCE_NAME_PREFIX = "machine"
  BOX_IMAGE = "generic/ubuntu2204"
  
  # Libvirt provider defaults
  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.host = "localhost"
    libvirt.uri = "qemu:///system"
    libvirt.cpus = 1
    libvirt.memory = 2048
    libvirt.cpu_mode = "host-model"
    # libvirt.storage_pool_name = "vagrant"
    libvirt.disk_bus = "virtio"
    # libvirt.volume_cache = "writeback"
  end

  # Configure the base box
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = false

  # Common provisioning script
  $common_script = <<-SCRIPT
    set -e
    echo "=== Provisioning VM: $(hostname) ==="
    
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        apt-get update -qq
        apt-get upgrade -y -qq
        apt-get install -y -qq curl wget vim htop tmux git net-tools
      elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
        yum update -y -q
        yum install -y -q curl wget vim htop tmux git net-tools
      fi
    fi
    
    echo "=== Provisioning complete ==="
  SCRIPT
  $rabbit_script = <<-SCRIPT
    set -e
    echo "=== Provisioning VM: $(hostname) ==="
    
    #!/bin/sh

    sudo apt-get install curl gnupg apt-transport-https -y

    ## Team RabbitMQ's signing key
    curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

    ## Add apt repositories maintained by Team RabbitMQ
    sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
    ## Modern Erlang/OTP releases
    ##
    deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main
    deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main

    ## Latest RabbitMQ releases
    ##
    deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
    deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
    EOF

    ## Update package indices
    sudo apt-get update -y

    ## Install Erlang packages
    sudo apt-get install -y erlang-base \
                            erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                            erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                            erlang-runtime-tools erlang-snmp erlang-ssl \
                            erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

    ## Install rabbitmq-server and its dependencies
    sudo apt-get install rabbitmq-server -y --fix-missing
    
    echo "=== Provisioning complete ==="
  SCRIPT
  $tomcat_script = <<-SCRIPT
    set -e
    echo "=== Provisioning VM: $(hostname) ==="
    sudo apt install fontconfig openjdk-21-jre
    sudo mkdir -p /opt/apache-tomcat-11
    wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.14/bin/apache-tomcat-11.0.14.tar.gz
    sudo tar xvfz -C /opt/apache-tomcat-11
    git clone https://github.com/abdelrahmanonline4/sourcecodeseniorwr.git
    cd sourcecodeseniorwr && mvn clean install
    sudo cp target/vprofile-v2.war $CATALINA_HOME/webapps/
    sudo $CATALINA_HOME/bin/startup.sh
    echo "=== Provisioning complete ==="
  SCRIPT
  $db_script = <<-SCRIPT
    set -e
    echo "=== Provisioning VM: $(hostname) ==="
    sudo apt-get install apt-transport-https curl -y 
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'

    sudo echo "# MariaDB 12.2 repository list - created 2025-11-22 14:06 UTC
    # https://mariadb.org/download/
    X-Repolib-Name: MariaDB
    Types: deb
    # deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
    # URIs: https://deb.mariadb.org/12.rc/ubuntu
    URIs: https://mariadb.mirror.liquidtelecom.com/repo/12.2/ubuntu
    Suites: jammy
    Components: main main/debug
    Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp" >> sudo tee /etc/apt/sources.list.d/mariadb.sources

    sudo apt-get update
    sudo apt-get install mariadb-server -y

    echo "=== Provisioning complete ==="
  SCRIPT
  # Create multiple VMs
  (1..NUM_INSTANCES).each do |i|
    config.vm.define "#{INSTANCE_NAME_PREFIX}-#{i}" do |vm|
      vm.vm.hostname = "#{INSTANCE_NAME_PREFIX}-#{i}"
      
      # Configure additional disk
      vm.vm.provider :libvirt do |libvirt|
        libvirt.storage :file, :size => "20G", :bus => "virtio", :type => "qcow2"
      end

      # NAT network - accessible from host
      vm.vm.network :private_network,
        :ip => "192.168.56.#{10 + i}",
        :libvirt__forward_mode => "nat"

      # Run provisioning script
      vm.vm.provision :shell, :inline => $common_script
    end
  end
end