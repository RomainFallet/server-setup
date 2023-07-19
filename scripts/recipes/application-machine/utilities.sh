#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/java/index.sh"

function AskApplicationMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing...................[0]
  - Set up a Java application.[1]
  - Install or upgrade Gitea..[2]"
  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    SetupJavaApplication
  fi
  if [[ "${applicationMachineAction:?}" == '2' ]]; then
    SetupGitea
  fi
}
