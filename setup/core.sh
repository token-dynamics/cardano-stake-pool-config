#!/usr/bin/env bash

log() {
  echo "relay.sh: $@"
}

grep 'source /opt/instance/env/core.sh' /home/ubuntu/.bashrc ||
  echo "source /opt/instance/env/core.sh" >> /home/ubuntu/.bashrc

sudo apt-get install -y docker.io
sudo apt-get install -y awscli

sudo docker pull amazon/aws-cli
sudo docker pull quay.io/tokendynamics/docker-cardano-node

# Download configs
sudo docker run --rm \
  -v "/opt/instance:/opt/instance" \
  -i amazon/aws-cli \
  s3 sync \
  ${config_path}/ \
  /opt/instance/

NODE_CONFIG=mainnet

log "Starting relay server"

# Run the node
sudo docker run -d \
  -v "/opt/instance:/opt/instance" \
  -e CARDANO_NODE_SOCKET_PATH="/opt/instance/db/socket" \
  -p 0.0.0.0:3001:3001 \
  -i inputoutput/cardano-node \
  run \
  --topology "/opt/instance/config/core-topology.json" \
  --database-path /opt/instance/db \
  --socket-path /opt/instance/db/socket \
  --host-addr 0.0.0.0 \
  --port 3001 \
  --config "/opt/instance/config/mainnet-config.json"

log "Done."
