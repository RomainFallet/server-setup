#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source-path=./
. "${SERVER_SETUP_HOME_PATH:?}/scripts/recipes/daily-backup-machine/utilities.sh"

SetUpSsh
SetUpFail2Ban
SetUpMachineFireWall
SetUpBasicSystemConfiguration
AskDailyBackupMachineActions
