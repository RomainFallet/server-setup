#!/bin/bash

# Exit script on error
set -e

### Restore backup with Rsync

# Ask destination path if not already set
destinationPath=$1
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the local destination path: " destinationPath
fi

# Ask ssh user if not already set
sshUser=$2
if [[ -z "${sshUser}" ]]
then
  read -r -p "Enter the SSH username of the source: " sshUser
fi

# Ask ssh hostname if not already set
sshHostname=$3
if [[ -z "${sshHostname}" ]]
then
  read -r -p "Enter the SSH hostname of the source: " sshHostname
fi

# Ask source path if not already set
sourcePath=$4
if [[ -z "${sourcePath}" ]]
then
  read -r -p "Enter the source path: " sourcePath
fi

# Restore backup
sudo rsync -av --delete "${sshUser}"@"${sshHostname}":"${sourcePath}" "${destinationPath}"
