#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function AskHostingMachineActions () {
  Ask hostingMachineAction "What do you want to do?
  - Nothing [0]
  - Install or upgrade Gitea [1]"
  if [[ "${hostingMachineAction:?}" == '1' ]]; then
    SetupGitea
  fi
}
