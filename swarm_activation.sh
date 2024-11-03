#!/bin/bash

# Define node names (as per your Vagrant setup)
MANAGER1="devserver1"
MANAGER2="devserver2"
WORKERS=("devserver3" "devserver4" "devserver5")

# Force all nodes to leave any existing swarm to ensure a clean state
echo "Forcing all nodes to leave any existing swarm..."

# Loop through all nodes and leave any existing swarm
for NODE in $MANAGER1 $MANAGER2 "${WORKERS[@]}"; do
    echo "Forcing $NODE to leave any existing swarm..."
    vagrant ssh $NODE -c "docker swarm leave --force"
done

# Initialize Docker Swarm on the first manager (Leader)
echo "Initializing Docker Swarm on Manager 1 ($MANAGER1)..."
vagrant ssh $MANAGER1 -c "docker swarm init --advertise-addr 10.10.10.2"

# Capture the join token for manager and worker nodes
MANAGER_JOIN_TOKEN=$(vagrant ssh $MANAGER1 -c "docker swarm join-token manager -q | tr -d '\r'")
WORKER_JOIN_TOKEN=$(vagrant ssh $MANAGER1 -c "docker swarm join-token worker -q | tr -d '\r'")

echo "Manager Join Token: $MANAGER_JOIN_TOKEN"
echo "Worker Join Token: $WORKER_JOIN_TOKEN"

# Join Manager 2 as a worker node (you can promote it later if needed)
echo "Making $MANAGER2 join as a worker node..."
vagrant ssh $MANAGER2 -c "docker swarm join --token $WORKER_JOIN_TOKEN 10.10.10.2:2377"

# Join worker nodes
for WORKER in "${WORKERS[@]}"; do
    echo "Making $WORKER join as a worker node..."
    vagrant ssh $WORKER -c "docker swarm join --token $WORKER_JOIN_TOKEN 10.10.10.2:2377"
done

# Display the status of the swarm cluster
echo "Docker Swarm Cluster Status:"
vagrant ssh $MANAGER1 -c "docker node ls"