#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/prerequisites/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/recipes/application-machine/utilities.sh"

SetUpApplicationMachinePrerequisites
SetUpApplicationMachineRestoreBackupScript
SetUpApplicationMachineBackupScript
AskBackupRestore
SetUpSsh
SetUpFail2Ban
SetUpMachineFireWall
SetUpBasicSystemConfiguration
AskApplicationMachineActions
