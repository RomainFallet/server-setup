#!/bin/bash

# Exit script on error
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

sudo mount /mnt/sda /dev/sda
