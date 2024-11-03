#!/bin/bash

# Array of Vagrant machine names
machines=("devserver1" "devserver2" "devserver3" "devserver4" "devserver5")

# Loop through each machine and SSH to install Docker
for machine in "${machines[@]}"
do
  echo "Connecting to $machine and installing Docker..."
  
  # Run the Docker installation commands via SSH
  vagrant ssh "$machine" -c "
    sudo apt-get update &&
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release &&
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg &&
    echo \
      \"deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
    sudo apt-get update &&
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io &&
    sudo usermod -aG docker vagrant &&
    sudo systemctl enable docker &&
    sudo systemctl start docker
  "

  echo "Docker installed on $machine."
done

