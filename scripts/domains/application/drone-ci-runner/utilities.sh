#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SelectAppropriateDroneCiRunnerArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "amd64"
  else
    echo "amd64"
  fi
}

function InstallDroneCiRunnerBinary () {
  binaryPath="${1}"
  sudo install -t /usr/local/bin "${binaryPath}"
}

function StartDroneCiRunnerService () {
  if systemctl status 'drone-runner-exec' &> /dev/null; then
    StopService 'drone-runner-exec'
    DisableService 'drone-runner-exec'
  fi
  RemoveFile /etc/systemd/system/drone-runner-exec.service
  sudo drone-runner-exec service install
  sudo drone-runner-exec service start
}
