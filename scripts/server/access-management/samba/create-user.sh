#!/bin/bash

# Exit script on error
set -e

# Ask for username if not provided
if [[ -z ${username} ]]; then
  read -r -p "Choose the new Samba user name: " username
  if [[ -z ${username} ]]; then
    echo "User name must not be empty." 1>&2
    exit 1
  fi
fi

# Ask for password if not provided
if [[ -z ${password} ]]; then
  read -r -p "Choose the new Samba user password: " password
  if [[ -z ${password} ]]; then
    echo "Password must not be empty." 1>&2
    exit 1
  fi
fi

# Create user if not exists
USER_ID=$(id -u "${username}" 2> /dev/null)
if [[ -z ${USER_ID} ]]; then
  if ! sudo useradd "${username}" && echo "${username}:${password}"| chpasswd; then
    echo "Unable to create the user." 1>&2
    exit 1
  fi
fi

# Create Samba password
echo "${password}
${password}" | sudo smbpasswd -a "${username}"

# Create Samba folder
sambafolder=/home/"${username}"/share
sudo mkdir -p /home/"${username}"/share

# Add User config
sambaconfig="
[${username}share]
comment = ${username} File Server Share
path = ${sambafolder}
browsable = yes
guest ok = yes
read only = no
create mask = 0664
directory mask = 0775"
sambaconfigfile=/etc/samba/smb.conf

if ! sudo grep "${sambaconfig}" "${sambaconfigfile}" > /dev/null
then
  echo "${sambaconfig}" | sudo tee -a "${sambaconfigfile}" > /dev/null
fi

# Restart Samba
sudo service smbd restart
