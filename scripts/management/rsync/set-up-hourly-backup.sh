#!/bin/bash

sourcePath=$1
if [[ -z "${sourcePath}" ]]
then
  read -r -p "Enter the source path of the backup: " sourcePath
fi

sshUser=$2
if [[ -z "${sshUser}" ]]
then
  read -r -p "Enter the SSH username to use for the remote backup: " sshUser
fi

sshHostname=$3
if [[ -z "${sshHostname}" ]]
then
  read -r -p "Enter the SSH hostname to use for the remote backup: " sshHostname
fi

destinationPath=$4
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the destination path on the remote side: " destinationPath
fi

destinationPath=$5
if [[ -z "${healthChecksUuid}" ]]
then
  read -r -p "Enter your healthchecks.io uuid to monitor your backup job (optional): " healthChecksUuid
fi

healthChecksMonitorCommand=""
if [[ -n "${healthChecksUuid}" ]]
then
  healthChecksMonitorCommand=" && curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
fi

backupScript="#!/bin/bash
(pgrep 'rsync' || rsync -av --delete ${sourcePath} ${sshUser}@${sshHostname}:${destinationPath})${healthChecksMonitorCommand}"
backupScriptPath=/etc/cron.hourly/backup.sh

if ! test -f "${backupScriptPath}"
then
  echo "${backupScript}" | sudo tee "${backupScriptPath}" > /dev/null
fi

pattern=$(echo "${backupScript}" | tr -d '\n')
content=$(< "${backupScriptPath}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${backupScript}" | sudo tee "${backupScriptPath}" > /dev/null
fi

sudo chmod +x "${backupScriptPath}"
