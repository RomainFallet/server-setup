#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"

function CreatePortForwardingService () {
  port="${1}"
  sshUserName="${2}"
  sshHostName="${3}"
  InstallPackageIfNotExisting 'autossh'
  autosshCommand="/usr/bin/autossh -N -R ${port}:localhost:${port} ${sshUserName}@${sshHostName}"
  CreateStartupService "autossh-${port}" "${autosshCommand}" 'root'
  RestartService "autossh-${port}"
}
