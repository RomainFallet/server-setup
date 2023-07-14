#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function ConfigureFileSharingHardDriveMountOnStartup () {
  mountConfiguration="/dev/sda    /mnt/sda    ext4    defaults    0    1"
  configurationPath=/etc/fstab
  AppendTextInFileIfNotFound "${mountConfiguration}" "${configurationPath}"
}

function ConfigureFolders () {
  for directoryPath in /mnt/sda/*/
  do
    directoryPath=${directoryPath%*/}
    if [[ "${directoryPath}" == '/mnt/sda/lost+found' ]]; then
      break
    fi
    exportConfiguration="${directoryPath}    192.168.0.0/255.255.0.0(rw,sync,no_subtree_check,all_squash,anonuid=65534,anongid=65534)"
    configurationPath=/etc/exports
    AppendTextInFileIfNotFound "${exportConfiguration}" "${configurationPath}"
  done
}

function ExportFolders () {
  sudo exportfs -rav
}
