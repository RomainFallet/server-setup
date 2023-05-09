#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/utilities.sh"
# shellcheck source=../../shared/variables/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"


function SetUpMailMachineBackups () {
  sshUserName="${1}"
  sshHostName="${2}"
  healthCheckId="${3}"
  AskIfNotSet sshUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet healthCheckId 'Enter your HealthChecks.io monitoring ID'
  # shellcheck disable=SC2088
  CreateBackupScript "/home/user-data/" "${sshUserName}" "${sshHostName}" "~/data" "${healthCheckId}"
  # shellcheck disable=SC2088
  CreateRestoreBackupScript  "~/data" "${sshUserName}" "${sshHostName}" "/home/user-data"
  CreateWeeklyBackupCronJob
}
