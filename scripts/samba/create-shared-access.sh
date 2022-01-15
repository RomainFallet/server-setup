#!/bin/bash

# Exit script on error
set -e

### Create Samba shared access for all Samba users

# Ask folder path if not already set
sharedFolderPath=${1}
if [[ -z ${sharedFolderPath} ]]; then
  read -r -p "Choose your shared folder path: " sharedFolderPath
fi

# Create shared group
sudo grep "shared" /etc/group > /dev/null || sudo addgroup shared

# Create shared folder
if ! test -d "${sharedFolderPath}"; then
  sudo mkdir -p "${sharedFolderPath}"
fi

# Set group ownership of shared folder
sudo chown root:shared "${sharedFolderPath}"

# Add config
sambaConfig="
[shared]
comment = Shared files
path = ${sharedFolderPath}
browsable = yes
read only = no
guest ok = no
valid users = @shared
create mask = 664
directory mask = 775
force group = shared

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

# Loop over each UNIX user
while read -r line; do
  userName=$(echo "${line}" | cut -d: -f1)
  homeDirectory=$(echo "${line}" | cut -d: -f6)

  # Check if it's a valid user
  if echo "${homeDirectory}" | grep '/home' > /dev/null
  then
    if [[ "${userName}" != 'syslog' ]]
    then
      # Set user group
      sudo usermod -G "${userName}",shared "${userName}"
    fi
  fi
done 3<&0 </etc/passwd

# Restart Samba
sudo service smbd restart
