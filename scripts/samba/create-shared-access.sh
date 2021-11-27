#!/bin/bash

# Exit script on error
set -e

### Create Samba shared access for all Samba users

# Ask folder path if not already set
sharedFolderPath=${1}
if [[ -z ${sharedFolderPath} ]]; then
  read -r -p "Choose your shared folder path: " sharedFolderPath
  if [[ -z ${sharedFolderPath} ]]; then
    echo "Path must not be empty." 1>&2
    exit 1
  fi
fi

# Create Samba folder
if ! test -d "${sharedFolderPath}"; then
  sudo mkdir -p "${sharedFolderPath}"
fi

# Add config
sambaConfig="
[shared]
comment = Shared files
path = ${sharedFolderPath}
browsable = yes
read only = no
guest ok = no
create mask = 0664
directory mask = 0775

[public]
comment = Shared files
path = ${sharedFolderPath}
browsable = yes
read only = yes
guest ok = yes"
sambaConfigfile=/etc/samba/smb.conf


pattern=$(echo "${sambaConfig}" | tr -d '\n')
content=$(< "${sambaConfigfile}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${sambaConfig}" | sudo tee -a "${sambaConfigfile}" > /dev/null
fi

# Restart Samba
sudo service smbd restart
