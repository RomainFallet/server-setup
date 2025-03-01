#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/port-forwarding/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function ForwardPortToRemoteServer () {
  portToForward="${1}"
  forwardServiceName="${2}"
  if [[ -z "${portToForward}" ]]; then
    Ask portToForward 'Enter port to forward to remote server'
  fi
  if [[ -z "${forwardServiceName}" ]]; then
    forwardServiceName="autossh-${portToForward}"
  fi
  AskIfNotSet portToForward 'Enter port to forward to remote server'
  AskIfNotSet sshUserNameForPortForwarding 'Enter SSH username of remote server'
  AskIfNotSet sshHostNameForPortForwarding 'Enter SSH hostname of remote server'
  CreatePortForwardingService "${forwardServiceName:?}" "${portToForward:?}" "${sshUserNameForPortForwarding:?}" "${sshHostNameForPortForwarding:?}"
}
