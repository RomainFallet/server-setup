#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/recipes/daily-backup-machine/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/prerequisites/index.sh"

SetUpBackupMachinePrerequisites
SetUpSsh
SetUpFail2Ban
SetUpMachineFireWall
SetUpBasicSystemConfiguration
AskDailyBackupMachineActions
LinkHomeFolderToExternalDisk
