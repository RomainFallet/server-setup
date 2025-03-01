#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/forgejo/index.sh"
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
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/drone-ci/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/drone-ci-runner/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/port-forwarding/index.sh"

function AskApplicationMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing............................[0]
  - Set up a Java application..........[1]
  - Set up a Phoenix application.......[2]
  - Install or upgrade Forgejo.........[3]
  - Install or upgrade Mattermost......[4]
  - Install or upgrade Listmonk........[5]
  - Install or upgrade Vaultwarden.....[6]
  - Install or upgrade Drone CI........[7]
  - Install or upgrade Drone CI Runner.[8]"
  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    SetupJavaApplication
  fi
  if [[ "${applicationMachineAction:?}" == '2' ]]; then
    SetupPhoenixApplication
  fi
  if [[ "${applicationMachineAction:?}" == '3' ]]; then
    SetupForgejo
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
  if [[ "${applicationMachineAction:?}" == '7' ]]; then
    SetupDroneCi
  fi
  if [[ "${applicationMachineAction:?}" == '8' ]]; then
    SetupDroneCiRunner
  fi
}
