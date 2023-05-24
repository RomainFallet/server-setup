#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function AskDailyBackupMachineActions () {
  Ask dailyBackupMachineAction "What do you want to do?
  - Nothing [0]
  - Create a user [1]"
  if [[ "${dailyBackupMachineAction:?}" == '1' ]]; then
    Ask usernameToCreate "Enter the username"
    CreateUserIfNotExisting "${usernameToCreate:?}"
  fi
}
