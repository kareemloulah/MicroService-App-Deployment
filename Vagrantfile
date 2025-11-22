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

  # # Common provisioning script
  # $common_script = <<-SCRIPT
  #   set -e
  #   echo "=== Provisioning VM: $(hostname) ==="
    
  #   if [ -f /etc/os-release ]; then
  #     . /etc/os-release
  #     if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
  #       apt-get update -qq
  #       apt-get upgrade -y -qq
  #       apt-get install -y -qq curl wget vim htop tmux git net-tools
  #     elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
  #       yum update -y -q
  #       yum install -y -q curl wget vim htop tmux git net-tools
  #     fi
  #   fi
    
  #   echo "=== Provisioning complete ==="
  # SCRIPT
  
  # # Create multiple VMs
  # (1..NUM_INSTANCES).each do |i|
  #   config.vm.define "#{INSTANCE_NAME_PREFIX}-#{i}" do |vm|
  #     vm.vm.hostname = "#{INSTANCE_NAME_PREFIX}-#{i}"
      
  #     # Configure additional disk
  #     vm.vm.provider :libvirt do |libvirt|
  #       libvirt.storage :file, :size => "20G", :bus => "virtio", :type => "qcow2"
  #     end

  #     # NAT network - accessible from host
  #     vm.vm.network :private_network,
  #       :ip => "192.168.56.#{10 + i}",
  #       :libvirt__forward_mode => "nat"

  #     # Run provisioning script
  #     vm.vm.provision :shell, :inline => $common_script
  #   end
  # end
vm_names = ["nginx", "tomcat", "mariadb", "memcached", "rabbitmq"]
vm_names.each_with_index do |name, index|
  config.vm.define name do |vm|

    vm.vm.hostname = name
    
    # Add disk
    vm.vm.provider :libvirt do |libvirt|
      libvirt.storage :file, :size => "20G", :bus => "virtio", :type => "qcow2"
    end

    # Unique IP for each VM
    vm.vm.network :private_network,
      ip: "192.168.56.#{10 + index + 1}",
      libvirt__forward_mode: "nat"

    # Script for this VM
    vm.vm.provision "shell", path: "scripts/#{name}.sh"
  end
end


end