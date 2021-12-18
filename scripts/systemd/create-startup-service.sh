#!/bin/bash

# Exit script on error
set -e

### Create a startup service

# Ask service name
serviceName=${1}
if [[ -z "${serviceName}" ]]
then
  read -r -p "Enter the name of your service without hypens (eg. myawesomeservice): " serviceName
fi

# Ask service command
serviceCommand=${2}
if [[ -z "${serviceCommand}" ]]
then
  read -r -p "Enter the full command to execute on system startup: " serviceCommand
fi

# Create service file
echo "[Unit]
Description=${serviceName}
After=network.target

[Service]
Type=simple
ExecStart=${serviceCommand}
User=root
Group=root

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/"${serviceName}".service > /dev/null

# Reload service files
sudo systemctl daemon-reload

# Enable service on startup
sudo systemctl enable "${serviceName}".service

# Start service now
sudo systemctl start "${serviceName}".service
