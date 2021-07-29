#!/bin/bash

# Exit script on error
set -e

### Samba file server

# Install
sudo apt install -y samba unzip

# Allow Samba connections
sudo ufw allow samba

# Download and install Windows Network Discovery
wget https://github.com/christgau/wsdd/archive/master.zip -P /tmp
unzip /tmp/master.zip -d /tmp
mv /tmp/wsdd-master/src/wsdd.py /tmp/wsdd-master/src/wsdd
sudo cp /tmp/wsdd-master/src/wsdd /usr/bin
sudo cp /tmp/wsdd-master/etc/systemd/wsdd.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl start wsdd
sudo systemctl enable wsdd
