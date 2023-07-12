#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/index.sh"

function AskHttpMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing [0]
  - Set up Gitea http server [1]"
  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    SetupGiteaHttpServer
  fi
}
