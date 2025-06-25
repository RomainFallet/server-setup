#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/web/index.sh"

function AskWebMachineActions () {
  Ask webMachineAction "What do you want to do?
  - Nothing...........................[0]
  - Create a user.....................[1]
  - Set up web static server..........[2]
  - Set up web static server for SPA..[3]
  - Set up web proxy server...........[4]
  - Set up web redirection server.....[5]"

  if [[ "${webMachineAction:?}" == '1' ]]; then
    Ask usernameToCreate "Enter the username"
    CreateUserIfNotExisting "${usernameToCreate:?}"
  fi
  if [[ "${webMachineAction:?}" == '2' ]]; then
    SetupWebStaticServer
  fi
  if [[ "${webMachineAction:?}" == '3' ]]; then
    SetupWebSpaServer
  fi
  if [[ "${webMachineAction:?}" == '4' ]]; then
    SetupWebProxyServer
  fi
  if [[ "${webMachineAction:?}" == '5' ]]; then
    SetupWebRedirectionServer
  fi
}
