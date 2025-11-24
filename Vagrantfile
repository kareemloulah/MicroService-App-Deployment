  #############################################
  ##### Hyper-v
  #############################################

# Vagrant.configure("2") do |config|
#   vms = [
#     {name: "mariadb", box: "generic/centos9s", ip: "192.168.56.15"},
#     {name: "rabbitmq", box: "generic/centos9s", ip: "192.168.56.14"},
#     {name: "memcache", box: "generic/centos9s", ip: "192.168.56.13"},
#     {name: "tomcat", box: "generic/centos9s", ip: "192.168.56.12"},
#     {name: "nginx", box: "generic/ubuntu2204", ip: "192.168.56.11"}
#   ]

#   vms.each do |vm|
#     config.vm.define vm[:name] do |machine|
#       machine.vm.box = vm[:box]
#       machine.vm.hostname = vm[:name]

#       # Private network (static IP)
#       machine.vm.network "private_network", ip: vm[:ip]

#       # Public network (DHCP)
#       machine.vm.network "public_network", bridge: "Default Switch"

#       # Hyper-V settings
#       machine.vm.provider "hyperv" do |hv|
#         hv.vmname = vm[:name]
#         hv.memory = 1536
#         hv.cpus = 1
#         hv.maxmemory = 2048
#         hv.linked_clone = true
#         hv.ip_address_timeout = 300
#       end

#       # # Provision script
#       # machine.vm.provision "shell", path: "scripts/#{vm[:name]}.sh"
#     end
#   end
# end

  #############################################
  ##### Libvirt
  #############################################

Vagrant.configure("2") do |config|
  vms = [
    {name: "mariadb",  box: "generic/centos9s",  ip: "192.168.56.15"},
    {name: "rabbitmq", box: "generic/centos9s",  ip: "192.168.56.14"},
    {name: "memcache", box: "generic/centos9s",  ip: "192.168.56.13"},
    {name: "tomcat",   box: "generic/centos9s",  ip: "192.168.56.12"},
    {name: "nginx",    box: "generic/ubuntu2204", ip: "192.168.56.11"}
  ]

  # Global Libvirt defaults
  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.uri = "qemu:///system"
    libvirt.memory = 1536
    libvirt.cpus = 1
  end

  vms.each do |vm|
    config.vm.define vm[:name] do |machine|
      machine.vm.box = vm[:box]
      machine.vm.hostname = vm[:name]

      # Private network (static IP)
      machine.vm.network "private_network",
        ip: vm[:ip],
        libvirt__network_name: "vagrant-libvirt"

      # VM-specific Libvirt overrides
      machine.vm.provider :libvirt do |lv|
        lv.memory = 1536
        lv.cpus = 1
      end

      # Optional provision script
      machine.vm.provision "shell", path: "scripts/#{vm[:name]}.sh"
    end
  end
end
