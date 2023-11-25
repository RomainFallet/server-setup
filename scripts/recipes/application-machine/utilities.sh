#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mattermost/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/listmonk/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/java/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/phoenix/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/vaultwarden/index.sh"

function AskApplicationMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing........................[0]
  - Set up a Java application......[1]
  - Set up a Phoenix application...[2]
  - Install or upgrade Gitea.......[3]
  - Install or upgrade Mattermost..[4]
  - Install or upgrade Listmonk....[5]
  - Install or upgrade Vaultwarden.[6]"
  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    SetupJavaApplication
  fi
  if [[ "${applicationMachineAction:?}" == '2' ]]; then
    SetupPhoenixApplication
  fi
  if [[ "${applicationMachineAction:?}" == '3' ]]; then
    SetupGitea
  fi
  if [[ "${applicationMachineAction:?}" == '4' ]]; then
    SetupMattermost
  fi
  if [[ "${applicationMachineAction:?}" == '5' ]]; then
    SetupListmonk
  fi
  if [[ "${applicationMachineAction:?}" == '6' ]]; then
    SetupVaultwarden
  fi
}
