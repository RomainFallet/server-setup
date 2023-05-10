#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/utilities.sh"

function CreateService () {
  name="${1}"
  executablePath="${2}"
  userName="${3}"
  fileContent="[Unit]
Description=${name}
After=network.target

[Service]
Type=simple
ExecStart=${executablePath}
Restart=on-failure
User=${userName}
Group=${userName}

[Install]
WantedBy=multi-user.target"
  filePath=/etc/systemd/system/"${name}".service
  SetFileContent "${fileContent}" "${filePath}"
  ReloadSystemdServiceFiles
  EnableSystemdService "${name}"
}

function RestartService () {
  RestartSystemdService 'fail2ban'
}
