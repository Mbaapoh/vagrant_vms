Vagrant.configure("2") do |config|

  # Define number of nodes
  num_nodes = 5  # Adjust this number to dynamically change the number of nodes

  (1..num_nodes).each do |i|
    config.vm.define "devserver#{i}" do |devserver|
      devserver.vm.box = "bento/ubuntu-24.04"
      
      # Private Network: Dynamic IPs starting from 10.10.10.2
      devserver.vm.network "private_network", ip: "10.10.10.#{"#{i + 1}"}"  # Starts from .2
      
      # Public Network: Explicitly set the bridge interface to Wi-Fi (or Ethernet)
      devserver.vm.network "public_network", bridge: "wlp0s20f3"  # Use "enp2s0" for Ethernet

      devserver.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 4
      end

      # Set unique hostnames based on the index
      if i == 1
        devserver.vm.hostname = "manager1"
      elsif i == 2
        devserver.vm.hostname = "manager2"
      else
        devserver.vm.hostname = "worker#{i - 2}"  # Starts from worker1 for the 3rd node
      end

      # Assign a unique SSH port for each VM to avoid conflicts (start from 2200)
      devserver.vm.network "forwarded_port", guest: 22, host: 2200 + i

      # Set boot timeout to 10 minutes (600 seconds)
      devserver.vm.boot_timeout = 600
    end
  end

end
