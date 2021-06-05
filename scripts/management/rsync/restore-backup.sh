#!/bin/bash

sshUser=$2
if [[ -z "${sshUser}" ]]
then
  read -r -p "Enter the SSH username of the source: " sshUser
fi

sshHostname=$3
if [[ -z "${sshHostname}" ]]
then
  read -r -p "Enter the SSH hostname of the source: " sshHostname
fi

sourcePath=$4
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the source path: " sourcePath
fi

destinationPath=$1
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the local destination path: " destinationPath
fi

rsync -av --delete "${sshUser}"@"${sshHostname}":"${sourcePath}" "${destinationPath}"
