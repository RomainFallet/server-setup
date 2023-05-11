#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/utilities.sh"

function CreateService () {
  name="${1}"
  executablePath="${2}"
  userName="${3}"
  workingDirectory="${4}"
  environmentVariables="${5}"

  workingDirectoryConfiguration=''
  environmentConfiguration=''
  if [[ -n "${workingDirectory}" ]]; then
    workingDirectoryConfiguration="
WorkingDirectory=${workingDirectory}"
  fi
  if [[ -n "${environmentVariables}" ]]; then
    environmentConfiguration="
Environment=${environmentVariables}"
  fi
  fileContent="[Unit]
Description=${name}
After=syslog.target
After=network.target

[Service]
Type=simple
ExecStart=${executablePath}
Restart=always
RestartSec=2s
User=${userName}
Group=${userName}${workingDirectoryConfiguration}${environmentConfiguration}

[Install]
WantedBy=multi-user.target"
  filePath=/etc/systemd/system/"${name}".service
  SetFileContent "${fileContent}" "${filePath}"
  ReloadSystemdServiceFiles
  EnableSystemdService "${name}"
}

function RestartService () {
  serviceName="${1}"
  RestartSystemdService "${serviceName}"
}
