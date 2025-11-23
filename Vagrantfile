Vagrant.configure("2") do |config|
  vms = [
    {name: "mariadb", box: "generic/centos9s", ip: "192.168.56.15"},
    {name: "rabbitmq", box: "generic/centos9s", ip: "192.168.56.14"},
    {name: "memcache", box: "generic/centos9s", ip: "192.168.56.13"},
    {name: "tomcat", box: "generic/centos9s", ip: "192.168.56.12"},
    {name: "nginx", box: "generic/ubuntu2204", ip: "192.168.56.11"}
  ]

  vms.each do |vm|
    config.vm.define vm[:name] do |machine|
      machine.vm.box = vm[:box]
      machine.vm.hostname = vm[:name]

      # Private network (static IP)
      machine.vm.network "private_network", ip: vm[:ip]

      # Public network (DHCP)
      machine.vm.network "public_network", bridge: "Default Switch"

      # Hyper-V settings
      machine.vm.provider "hyperv" do |hv|
        hv.vmname = vm[:name]
        hv.memory = 1536
        hv.cpus = 1
        hv.maxmemory = 2048
        hv.linked_clone = true
        hv.ip_address_timeout = 300
      end

      # # Provision script
      # machine.vm.provision "shell", path: "scripts/#{vm[:name]}.sh"
    end
  end

  # ### DATABASE ###
  # config.vm.define "mariadb" do |machine|
  #   machine.vm.box = 'generic/centos9s'
  #   machine.vm.network "private_network", ip: '192.168.56.15'
  #   machine.vm.network "public_network", bridge: "Default Switch"
  #   machine.vm.hostname = "mariadb"
  #   machine.vm.provider "hyperv" do |hyperv|
  #     hyperv.vmname = "mariadb"
  #     hyperv.memory = 1536          # 4GB RAM
  #     hyperv.cpus = 1               # 2 CPU cores
  #     hyperv.maxmemory = 1536       # Dynamic memory up to 6GB
  #     hyperv.linked_clone = true    # Use differencing disk
  #     hyperv.ip_address_timeout = 300
  #   end
  # end

  # ### RABBITMQ ###
  # config.vm.define "rabbitmq" do |machine|
  #   machine.vm.box = 'generic/centos9s'
  #   machine.vm.network "private_network", ip: '192.168.56.14'
  #   machine.vm.network "public_network", bridge: "Default Switch"
  #   machine.vm.hostname = "rabbitmq"
  #   machine.vm.provider "hyperv" do |hyperv|
  #     hyperv.vmname = "rabbitmq"
  #     hyperv.memory = 1536          # 4GB RAM
  #     hyperv.cpus = 1               # 2 CPU cores
  #     hyperv.maxmemory = 1536       # Dynamic memory up to 6GB
  #     hyperv.linked_clone = true    # Use differencing disk
  #     hyperv.ip_address_timeout = 300
  #   end
  # end

  # ### MEMCACHE ###
  # config.vm.define "memcache" do |machine|
  #   machine.vm.box = 'generic/centos9s'
  #   machine.vm.network "private_network", ip: '192.168.56.13'
  #   machine.vm.network "public_network", bridge: "Default Switch"
  #   machine.vm.hostname = "memcache"
  #   machine.vm.provider "hyperv" do |hyperv|
  #     hyperv.vmname = "memcache"
  #     hyperv.memory = 1536          # 4GB RAM
  #     hyperv.cpus = 1               # 2 CPU cores
  #     hyperv.maxmemory = 1536       # Dynamic memory up to 6GB
  #     hyperv.linked_clone = true    # Use differencing disk
  #     hyperv.ip_address_timeout = 300
  #   end
  # end
  # ### TOMCAT ###
  # config.vm.define "tomcat" do |machine|
  #   machine.vm.box = 'generic/centos9s'
  #   machine.vm.network "private_network", ip: '192.168.56.12'
  #   machine.vm.network "public_network", bridge: "Default Switch"
  #   machine.vm.hostname = "tomcat"
  #   machine.vm.provider "hyperv" do |hyperv|
  #     hyperv.vmname = "tomcat"
  #     hyperv.memory = 1536          # 4GB RAM
  #     hyperv.cpus = 1               # 2 CPU cores
  #     hyperv.maxmemory = 1536       # Dynamic memory up to 6GB
  #     hyperv.linked_clone = true    # Use differencing disk
  #     hyperv.ip_address_timeout = 300
  #   end
  # end
  # ### NGINX ###
  # config.vm.define "nginx" do |machine|
  #   machine.vm.box = 'generic/ubuntu2204'
  #   machine.vm.network "private_network", ip: '192.168.56.11'
  #   machine.vm.network "public_network", bridge: "Default Switch"
  #   machine.vm.hostname = "nginx"
  #   machine.vm.provider "hyperv" do |hyperv|
  #     hyperv.vmname = "nginx"
  #     hyperv.memory = 1536          # 4GB RAM
  #     hyperv.cpus = 1               # 2 CPU cores
  #     hyperv.maxmemory = 1536       # Dynamic memory up to 6GB
  #     hyperv.linked_clone = true    # Use differencing disk
  #     hyperv.ip_address_timeout = 300
  #   end
  # end
end