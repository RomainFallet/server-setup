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
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/http/index.sh"

function AskHttpMachineActions () {
  Ask applicationMachineAction "What do you want to do?
  - Nothing...........................[0]
  - Set up http static server.........[1]
  - Set up http static server for SPA.[2]
  - Set up http proxy server..........[3]
  - Set up http redirection server....[4]
  - Set up Gitea http server..........[5]
  - Set up Mattermost http server.....[6]
  - Set up Listmonk http server.  ....[7]"
  if [[ "${applicationMachineAction:?}" == '1' ]]; then
    SetupHttpStaticServer
  fi
  if [[ "${applicationMachineAction:?}" == '2' ]]; then
    SetupHttpSpaServer
  fi
  if [[ "${applicationMachineAction:?}" == '3' ]]; then
    SetupHttpProxyServer
  fi
  if [[ "${applicationMachineAction:?}" == '4' ]]; then
    SetupHttpRedirectionServer
  fi
  if [[ "${applicationMachineAction:?}" == '5' ]]; then
    SetupGiteaHttpServer
  fi
  if [[ "${applicationMachineAction:?}" == '6' ]]; then
    SetupMattermostHttpServer
  fi
  if [[ "${applicationMachineAction:?}" == '7' ]]; then
    SetupListmonkHttpServer
  fi
}
