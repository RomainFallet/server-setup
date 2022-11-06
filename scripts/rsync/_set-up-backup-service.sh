#!/bin/bash

# Exit script on error
set -e

### Set up daily backup with Rsync

# Ask source path if not already set
sourcePath=${1}
if [[ -z "${sourcePath}" ]]
then
  read -r -p "Enter the source path of the backup: " sourcePath
fi

# Ask destination path if not already set
destinationPath=${2}
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the destination path on the remote side: " destinationPath
fi

# Ask ssh user if not already set
sshUser=${3}
if [[ -z "${sshUser}" ]]
then
  read -r -p "Enter the SSH username to use for the remote backup: " sshUser
fi

# Ask ssh hostname if not already set
sshHostname=${4}
if [[ -z "${sshHostname}" ]]
then
  read -r -p "Enter the SSH hostname to use for the remote backup: " sshHostname
fi

# Ask health checks uuid if not already set
healthChecksUuid=${5}
if [[ -z "${healthChecksUuid}" ]]
then
  read -r -p "Enter your healthchecks.io uuid to monitor your backup job (optional): " healthChecksUuid
fi

# Create backup script
backupScript="#!/bin/bash
set -e
/usr/bin/rsync -av --delete --progress ${sourcePath} ${sshUser}@${sshHostname}:${destinationPath}
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
backupScriptPath=/opt/rsync-backup.sh
echo "${backupScript}" | sudo tee "${backupScriptPath}" > /dev/null

# Create service file
echo "[Unit]
Description=Rsync backup
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash ${backupScriptPath}
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/rsync-backup.service > /dev/null

# Reload service files
sudo systemctl daemon-reload
