#!/bin/bash

# Exit script on error
set -e

### Set up data disk for all UNIX users

# Create mount point
if ! test -d /mnt/sda
then
  sudo mkdir /mnt/sda
fi

# Create mount config
permanentMountConfig="/dev/sda /mnt/sda ext4 defaults 0 1"
if ! grep "${permanentMountConfig}" /etc/fstab > /dev/null
then
  echo "${permanentMountConfig}" | sudo tee -a /etc/fstab > /dev/null
fi

# Mount folder
if ! findmnt -t ext4 -S /dev/sda -T /mnt/sda > /dev/null
then
  sudo mount /dev/sda /mnt/sda
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
      # Create data folder
      dataPath=/mnt/sda/"${userName}"
      if ! test -d "${dataPath}"
      then
        sudo mkdir "${dataPath}"
      fi

      # Create symlink from the user home directory
      symlinkPath="${homeDirectory}"/data
      if [[ ! -L "${symlinkPath}" ]] || [[ ! -e "${symlinkPath}" ]]
      then
        sudo rm -f "${symlinkPath}"
        sudo ln -s "${dataPath}" "${symlinkPath}"
      fi

      # Give permission to the user
      sudo chown -h "${userName}":"${userName}" "${dataPath}" "${symlinkPath}"
    fi
  fi
done </etc/passwd
