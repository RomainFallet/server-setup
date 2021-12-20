#!/bin/bash

# Exit script on error
set -e

### Samba file server

# Install
spkg -s samba > /dev/null || sudo apt install -y samba
spkg -s unzip > /dev/null || sudo apt install -y unzip

# Allow Samba connections
sudo ufw allow samba

# Backup config file
sambaConfigPath=/etc/samba/smb.conf
sambaConfigbBackupPath=/etc/samba/smb.conf.backup
if ! test -f "${sambaConfigbBackupPath}"
then
  sudo cp "${sambaConfigPath}" "${sambaConfigbBackupPath}"
fi

# Download and install Windows Network Discovery
if ! sudo systemctl is-active --quiet wsdd
then
  wget https://github.com/christgau/wsdd/archive/master.zip -P /tmp
  unzip /tmp/master.zip -d /tmp
  mv /tmp/wsdd-master/src/wsdd.py /tmp/wsdd-master/src/wsdd
  sudo cp /tmp/wsdd-master/src/wsdd /usr/bin
  sudo cp /tmp/wsdd-master/etc/systemd/wsdd.service /etc/systemd/system
  sudo rm /tmp/master.zip
  sudo rm -rf /tmp/wsdd-master
  sudo systemctl daemon-reload
  sudo systemctl start wsdd
  sudo systemctl enable wsdd
fi

# Allow WSD connections
sudo ufw allow 3702/udp
sudo ufw allow 5357/tcp
