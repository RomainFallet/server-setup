#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/drone-ci/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mattermost/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/listmonk/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/web/index.sh"

function AskWebMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing...........................[0]
  - Create a user.....................[1]
  - Set up web static server..........[2]
  - Set up web static server for SPA..[3]
  - Set up web proxy server...........[4]
  - Set up web redirection server.....[5]
  - Set up Gitea web server...........[6]
  - Set up Mattermost web server......[7]
  - Set up Listmonk web server.  .....[8]
  - Set up Drone CI web server.  .....[9]"

  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    Ask usernameToCreate "Enter the username"
    CreateUserIfNotExisting "${usernameToCreate:?}"
  fi
  if [[ "${applicationMachineAction:?}" == '2' ]]; then
    SetupWebStaticServer
  fi
  if [[ "${applicationMachineAction:?}" == '3' ]]; then
    SetupWebSpaServer
  fi
  if [[ "${applicationMachineAction:?}" == '4' ]]; then
    SetupWebProxyServer
  fi
  if [[ "${applicationMachineAction:?}" == '5' ]]; then
    SetupWebRedirectionServer
  fi
  if [[ "${applicationMachineAction:?}" == '6' ]]; then
    SetupGiteaWebServer
  fi
  if [[ "${applicationMachineAction:?}" == '7' ]]; then
    SetupMattermostWebServer
  fi
  if [[ "${applicationMachineAction:?}" == '8' ]]; then
    SetupListmonkWebServer
  fi
  if [[ "${applicationMachineAction:?}" == '9' ]]; then
    SetupDroneCiWebServer
  fi
}
