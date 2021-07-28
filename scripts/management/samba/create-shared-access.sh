#!/bin/bash

# Exit script on error
set -e

# Create Samba folder
sambafolder=/mnt/sda/shared
if ! test -d "${sambafolder}"; then
  sudo mkdir -p "${sambafolder}"
fi

# Add config
sambaconfig="
[shared]
comment = Shared files
path = ${sambafolder}
browsable = yes
read only = no
guest ok = no
create mask = 0664
directory mask = 0775

[public]
comment = Shared files
path = ${sambafolder}
browsable = yes
read only = yes
guest ok = yes"
sambaconfigfile=/etc/samba/smb.conf


pattern=$(echo "${sambaconfig}" | tr -d '\n')
content=$(< "${sambaconfigfile}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${sambaconfig}" | sudo tee -a "${sambaconfigfile}" > /dev/null
fi

# Restart Samba
sudo service smbd restart
