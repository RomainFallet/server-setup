#!/bin/bash

# Exit script on error
set -e

# Ask for username if not provided
username=$1
if [[ -z ${username} ]]; then
  read -r -p "Choose the Samba user: " username
  if [[ -z ${username} ]]; then
    echo "User name must not be empty." 1>&2
    exit 1
  fi
fi

# Check if user already exists
if sudo pdbedit -L | grep "${username}"; then
  echo "Samba user already exists."
  exit 0
fi

# Ask for password if not provided
password=$2
if [[ -z ${password} ]]; then
  read -r -p "Create the Samba password for user \"${username}\": " password
  if [[ -z ${password} ]]; then
    echo "Password must not be empty." 1>&2
    exit 1
  fi
fi

# Create Samba password
echo "${password}
${password}" | sudo smbpasswd -a "${username}"

# Create Samba folder
sambafolder=/home/"${username}"/data
if ! test -d "${sambafolder}"; then
  sudo mkdir -p "${sambafolder}"
fi

# Add User config
sambaconfig="
[${username}]
comment = ${username} files
path = ${sambafolder}
browsable = yes
valid users = %S
read only = no
guest ok = no
create mask = 0664
directory mask = 0775"
sambaconfigfile=/etc/samba/smb.conf


pattern=$(echo "${sambaconfig}" | tr -d '\n')
content=$(< "${sambaconfigfile}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${sambaconfig}" | sudo tee -a "${sambaconfigfile}" > /dev/null
fi

# Restart Samba
sudo service smbd restart
