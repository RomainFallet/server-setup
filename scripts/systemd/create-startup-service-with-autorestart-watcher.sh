#!/bin/bash

# Exit script on error
set -e

### Create a startup service with autorestart watcher

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

# Ask service watcher path
serviceWatcherPath=${3}
if [[ -z "${serviceWatcherPath}" ]]
then
  read -r -p "Enter the full path if the directory to watch for changes: " serviceWatcherPath
fi

# Ask service username
serviceUsername=${4}
if [[ -z "${serviceUsername}" ]]
then
  read -r -p "Enter the username that will execute the command: " serviceUsername
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

echo "[Unit]
Description=${serviceName} restarter
After=network.target
StartLimitIntervalSec=5
StartLimitBurst=1

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart ${serviceName}.service

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/"${serviceName}"-watcher.service > /dev/null

echo "[Path]
Unit=${serviceName}-watcher.service
PathChanged=${serviceWatcherPath}

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/"${serviceName}"-watcher.path > /dev/null

# Reload service files
sudo systemctl daemon-reload

# Enable service on startup
sudo systemctl enable "${serviceName}".service
sudo systemctl enable "${serviceName}"-watcher.{path,service}

# Start service now
sudo systemctl start "${serviceName}".service
sudo systemctl start "${serviceName}"-watcher.{path,service}
