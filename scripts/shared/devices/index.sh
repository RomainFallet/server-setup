#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function MountDeviceAutomaticallyIfConnected () {
  deviceName="${1}"
  if lsblk /dev/"${deviceName}" > /dev/null; then
    sudo mkdir -p /mnt/"${deviceName}"
    sudo mount /dev/"${deviceName}" /mnt/"${deviceName}"
    mountConfiguration="/dev/sda    /mnt/sda    ext4    defaults    0    1"
    configurationPath=/etc/fstab
    AppendTextInFileIfNotFound "${mountConfiguration}" "${configurationPath}"
  fi
}
