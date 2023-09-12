#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/drone-ci-runner/utilities.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SetupDroneCiRunner () {
  architecture=$(SelectAppropriateDroneCiRunnerArchitecture)
  downloadUrl="https://github.com/drone-runners/drone-runner-exec/releases/latest/download/drone_runner_exec_linux_${architecture}.tar.gz"
  downloadPath=/tmp/drone_runner_exec_linux.tar.gz
  DownloadFile "${downloadUrl}" "${downloadPath}"
  ExctractTarFile "${downloadPath}" /tmp
  InstallDroneCiRunnerBinary /tmp/drone-runner-exec
  AskIfNotSet droneDomainName "Enter your Drone CI domain name"
  AskIfNotSet droneSharedSecretKey "Enter your Drone CI shared secret key"
  droneCiRunnerConfiguration="DRONE_RPC_PROTO=https
DRONE_RPC_HOST=${droneDomainName?:}
DRONE_RPC_SECRET=${droneSharedSecretKey?:}"
  droneCiRunnerConfigurationPath=/etc/drone-runner-exec/config
  SetFileContent "${droneCiRunnerConfiguration}" "${droneCiRunnerConfigurationPath}"
  StartDroneCiRunnerService
}
