#!/bin/bash

# Exit script on error
set -e

### Set up daily backup with Rsync

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")

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

# Setup backup service
bash "${directoryPath}"/_set-up-backup-service.sh "${sourcePath}" "${destinationPath}" "${sshUser}" "${sshHostname}" "${healthChecksUuid}"

# Create cron backup script
cronBackupScript="#!/bin/bash
set -e
systemctl start rsync-backup.service"
cronBackupScriptPath=/etc/cron.daily/rsync-backup
echo "${cronBackupScript}" | sudo tee "${cronBackupScriptPath}" > /dev/null

# Make backup script executable
sudo chmod +x "${cronBackupScriptPath}"
