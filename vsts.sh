#!/bin/bash

# Variables
PAT="YOUT PAT"
URL="YOUR ORG URL"
AGENT_NAME="DevOpsAgent"
POOL_NAME="Default"
AGENT_WORK_DIR="_work"

# Download the agent package
wget https://vstsagentpackage.azureedge.net/agent/3.241.0/vsts-agent-linux-x64-3.241.0.tar.gz

# Extract the package
tar -xf vsts-agent-linux-x64-3.241.0.tar.gz

# Configure the agent
# Note: The --unattended flag and other options allow for non-interactive configuration
./config.sh --unattended \
  --agent $AGENT_NAME \
  --url $URL \
  --auth pat \
  --token $PAT \
  --pool $POOL_NAME \
  --work $AGENT_WORK_DIR \
  --replace

# Install the agent as a service
sudo ./svc.sh install

# Start the agent service
sudo ./svc.sh start
