#!/bin/bash

function CreateApplicationUserIfNotExisting () {
  userName="${1}"
  if ! id --user "${userName}" &> /dev/null; then
    sudo adduser --system --shell /bin/bash --group --disabled-password --home /home/"${userName}" "${userName}"
  fi
}

function SetDirectoryOwnership () {
  directoryPath="${1}"
  userName="${2}"
  groupName="${3}"
  if [[ -z "${groupName}" ]]; then
    groupName="${userName}"
  fi
  sudo chown -R "${userName}":"${groupName}" "${directoryPath}"
}


function SetFileOwnership () {
  filePath="${1}"
  userName="${2}"
  groupName="${3}"
  if [[ -z "${groupName}" ]]; then
    groupName="${userName}"
  fi
  sudo chown "${userName}":"${groupName}" "${filePath}"
}
