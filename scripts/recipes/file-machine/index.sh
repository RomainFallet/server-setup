#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/prerequisites/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/file-sharing/index.sh"

SetUpFileMachinePrerequisites
SetUpFileMachineRestoreBackupScript
SetUpFileMachineBackupScript
SetUpSsh
SetUpFail2Ban
SetUpFileMachineFireWall
SetUpBasicSystemConfiguration
SetUpFileSharing
