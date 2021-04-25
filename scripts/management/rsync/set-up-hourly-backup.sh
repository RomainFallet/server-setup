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

backupScript="pgrep 'rsync' || rsync -av --delete ${sourcePath} ${sshUser}@${sshHostname}:${destinationPath}"
backupScriptPath=/etc/cron.hourly/backup.sh

if ! test -f "${backupScriptPath}"
then
  echo "${backupScript}" | sudo tee "${backupScriptPath}" > /dev/null
fi

if ! grep "${backupScript}" "${backupScriptPath}"
then
  echo "${backupScript}" | sudo tee "${backupScriptPath}" > /dev/null
fi
