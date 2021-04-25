#!/bin/bash

set -e

if ! test -d /mnt/sda
then
  sudo mkdir /mnt/sda
fi

permanentMountConfig="/dev/sda /mnt/sda ext4 defaults 0 1"
if ! grep "${permanentMountConfig}" /etc/fstab > /dev/null
then
  echo "${permanentMountConfig}" | sudo tee -a /etc/fstab > /dev/null
fi

if ! findmnt -t ext4 -S /dev/sda -T /mnt/sda
then
  sudo mount /dev/sda /mnt/sda
fi

while read -r line; do
  userName=$(echo "${line}" | cut -d: -f1)
  homeDirectory=$(echo "${line}" | cut -d: -f6)
  if echo "${homeDirectory}" | grep '/home' > /dev/null
  then
    if [[ "${userName}" != 'syslog' ]]
    then
      symlinkPath="${homeDirectory}"/data
      dataPath=/mnt/sda/"${userName}"

      if ! test -d "${dataPath}"
      then
        sudo mkdir "${dataPath}"
      fi

      if [[ ! -L "${symlinkPath}" ]] || [[ ! -e "${symlinkPath}" ]]
      then
        sudo rm -f "${symlinkPath}"
        sudo ln -s "${dataPath}" "${symlinkPath}"
      fi

      sudo chown -h "${userName}":"${userName}" "${dataPath}" "${symlinkPath}"
    fi
  fi
done </etc/passwd
