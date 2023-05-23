#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"


function SetUpMailMachineBackups () {
  sshUserName="${1}"
  sshHostName="${2}"
  healthCheckId="${3}"
  AskIfNotSet sshUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet healthCheckId 'Enter your HealthChecks.io monitoring ID'
  # shellcheck disable=SC2088
  CreateMailMachineBackupScript "${sshUserName}" "${sshHostName}" "${healthCheckId}"
  # shellcheck disable=SC2088
  CreateMailMachineRestoreBackupScript "${sshUserName}" "${sshHostName}"
  CreateDailyBackupCronJob
  RestoreMailMachineBackupScript
}
