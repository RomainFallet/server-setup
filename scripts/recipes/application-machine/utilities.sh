#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/web/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/forgejo/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mattermost/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/listmonk/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/java/index.sh"
# shellcheck source-path=../../../
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/vaultwarden/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/port-forwarding/index.sh"

function AskApplicationMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing............................[0]
  - Create a user......................[1]
  - Set up a Java application..........[2]
  - Install or upgrade Forgejo.........[3]
  - Install or upgrade Mattermost......[4]
  - Install or upgrade Listmonk........[5]
  - Install or upgrade Vaultwarden.....[6]
  - Set up web static server...........[7]
  - Set up web static server for SPA...[8]
  - Set up web proxy server............[9]
  - Set up web redirection server......[10]"

  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    Ask usernameToCreate "Enter the username"
    CreateUserIfNotExisting "${usernameToCreate:?}"
  fi
  if [[ "${applicationMachineAction:?}" == '2' ]]; then
    SetupJavaApplication
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
    SetupWebStaticServer
  fi
  if [[ "${applicationMachineAction:?}" == '8' ]]; then
    SetupWebSpaServer
  fi
  if [[ "${applicationMachineAction:?}" == '9' ]]; then
    SetupWebProxyServer
  fi
  if [[ "${applicationMachineAction:?}" == '10' ]]; then
    SetupWebRedirectionServer
  fi
}
