#!/bin/bash

# Exit script on error
set -e

### Deluge

# Add official repository
test -f /etc/apt/sources.list.d/deluge-team-ubuntu-stable-*.list || sudo add-apt-repository -y ppa:deluge-team/stable

# Install
dpkg -s deluged &> /dev/null || sudo apt install -y deluged
dpkg -s deluge-console &> /dev/null || sudo apt install -y deluge-console

# Create shared group
sudo grep "shared" /etc/group > /dev/null || sudo addgroup shared

# Add Deluge user
directoryPath=/var/lib/deluge
sudo grep "deluge" /etc/passwd > /dev/null || sudo adduser --system --disabled-password --group --home "${directoryPath}" deluge

# Set user group
sudo usermod -g shared deluge

# Create deluge daemon admin
test -d /var/lib/deluge/.config/deluge || sudo mkdir -p /var/lib/deluge/.config/deluge
sudo chown -R deluge:deluge /var/lib/deluge
authFilePath=/var/lib/deluge/.config/deluge/auth
sudo grep "deluge" "${authFilePath}" &> /dev/null || echo "deluge:deluge:10" | sudo tee -a "${authFilePath}" > /dev/null

# Create log directory
sudo mkdir -p /var/log/deluge
sudo chown -R deluge:deluge /var/log/deluge
sudo chmod -R 750 /var/log/deluge

# Create daemon config file
sudo mkdir -p /etc/systemd/system/deluged.service.d
echo "[Service]
User=deluge
Group=shared
" | sudo tee /etc/systemd/system/deluged.service.d/user.conf > /dev/null

# Create service file
echo "[Unit]
Description=Deluge Bittorrent Client Daemon
Documentation=man:deluged
After=network-online.target mnt-sda.mount
Requires=mnt-sda.mount
BindsTo=mnt-sda.mount

[Service]
Type=simple
UMask=007
ExecStart=/usr/bin/deluged -d -l /var/log/deluge/daemon.log -L warning --logrotate
Restart=on-failure
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target mnt-sda.mount
" | sudo tee /etc/systemd/system/deluged.service > /dev/null

# Allow ports
sudo ufw allow 56881/tcp
sudo ufw allow 56881/udp

# Reload service files
sudo systemctl daemon-reload

# Enable service on startup
sudo systemctl enable deluged.service

# Start service now
sudo systemctl start deluged.service
