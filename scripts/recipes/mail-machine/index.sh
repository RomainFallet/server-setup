#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mailinabox/index.sh"

SetUpMailInABoxFixPermissionsScript
SetUpMailMachineRestoreBackupScript
AskBackupRestore
SetUpSsh
SetUpAutomaticUpdates
SetUpMailInABox
SetUpMailMachineBackupScript
