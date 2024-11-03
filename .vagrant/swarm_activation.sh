#!/bin/bash

# Define machine names and their IPs
declare -A machines
machines=(
  ["devserver1"]="10.10.10.2"
  ["devserver2"]="10.10.10.3"
)

# Function to check if a node is part of a swarm
check_swarm_status() {
  local machine="$1"
  
  vagrant ssh "$machine" -c "docker info --format '{{.Swarm.LocalNodeState}}'"
}

# Leave swarm if the node is already part of it
leave_swarm_if_needed() {
  local machine="$1"
  
  local status=$(check_swarm_status "$machine")
  if [ "$status" = "active" ]; then
    echo "$machine is already part of a Swarm, leaving..."
    vagrant ssh "$machine" -c "docker swarm leave --force" || {
      echo "Failed to leave swarm on $machine"
    }
  fi
}

# Leave any existing swarms on both nodes
for key in "${!machines[@]}"; do
  leave_swarm_if_needed "$key"
done

# Initialize Docker Swarm on devserver1 (first master)
echo "Initializing Docker Swarm on devserver1 (first master)..."
vagrant ssh devserver1 -c "
  docker swarm init --advertise-addr ${machines[devserver1]}
" || {
  echo "Failed to initialize swarm on devserver1"
}

# Get the join-token for additional master nodes
SWARM_JOIN_CMD=$(vagrant ssh devserver1 -c "docker swarm join-token manager -q")
if [[ -z "$SWARM_JOIN_CMD" ]]; then
  echo "Failed to retrieve the Swarm join token."
  exit 1
fi

# Join devserver2 as an additional master node
echo "Connecting to devserver2 and joining Docker Swarm as an additional master..."
vagrant ssh devserver2 -c "
  docker swarm join --token $SWARM_JOIN_CMD ${machines[devserver1]}:2377
" || {
  echo "Failed to join devserver2 to the Swarm."
  exit 1
}

echo "Docker Swarm setup completed."