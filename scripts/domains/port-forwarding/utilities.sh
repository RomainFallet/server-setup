#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"

function CreatePortForwardingService () {
  serviceName="${1}"
  port="${2}"
  sshUserName="${3}"
  sshHostName="${4}"
  autosshCommand="/usr/bin/autossh -N -R ${port}:localhost:${port} ${sshUserName}@${sshHostName}"
  CreateStartupService "${serviceName}" "${autosshCommand}" 'root'
  RestartService "${serviceName}"
}
