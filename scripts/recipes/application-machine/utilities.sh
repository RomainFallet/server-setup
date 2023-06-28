#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function AskApplicationMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing [0]
  - Install or upgrade Gitea [1]"
  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    SetupGitea
  fi
}
