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

# Ask ssh user if not already set
sshUser=${2}
if [[ -z "${sshUser}" ]]
then
  read -r -p "Enter the SSH username to use for the remote backup: " sshUser
fi

# Ask ssh hostname if not already set
sshHostname=${3}
if [[ -z "${sshHostname}" ]]
then
  read -r -p "Enter the SSH hostname to use for the remote backup: " sshHostname
fi

# Ask destination path if not already set
destinationPath=${4}
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the destination path on the remote side: " destinationPath
fi

# Ask health checks uuid if not already set
healthChecksUuid=${5}
if [[ -z "${healthChecksUuid}" ]]
then
  read -r -p "Enter your healthchecks.io uuid to monitor your backup job (optional): " healthChecksUuid
fi

# Health checks ping command
healthChecksMonitorCommand=""
if [[ -n "${healthChecksUuid}" ]]
then
  healthChecksMonitorCommand="curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
fi

# Create backup script
backupScript="#!/bin/bash
set -e
rsync -av --delete ${sourcePath} ${sshUser}@${sshHostname}:${destinationPath}
${healthChecksMonitorCommand}"
backupScriptPath=/etc/cron.daily/rsync-backup
if ! test -f "${backupScriptPath}"
then
  sudo touch "${backupScriptPath}"
fi
pattern=$(echo "${backupScript}" | tr -d '\n')
content=$(< "${backupScriptPath}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${backupScript}" | sudo tee "${backupScriptPath}" > /dev/null
fi

# Make backup script executable
sudo chmod +x "${backupScriptPath}"
