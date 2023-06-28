#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"


function SetUpMailMachineBackupScript () {
  AskIfNotSet sshUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet healthCheckId 'Enter your HealthChecks.io monitoring ID'
  CreateMailMachineBackupScript "${sshUserName:?}" "${sshHostName:?}" "${healthCheckId:?}"
  CreateDailyBackupCronJob
}

function SetUpMailMachineRestoreBackupScript () {
  AskIfNotSet sshUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHostName 'Enter SSH hostname of backup machine'
  CreateMailMachineRestoreBackupScript "${sshUserName:?}" "${sshHostName:?}"
}

function SetUpApplicationMachineBackupScript () {
  AskIfNotSet sshUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet healthCheckId 'Enter your HealthChecks.io monitoring ID'
  CreateApplicationMachineBackupScript "${sshUserName:?}" "${sshHostName:?}" "${healthCheckId:?}"
  CreateDailyBackupCronJob
}

function SetUpApplicationMachineRestoreBackupScript () {
  AskIfNotSet sshUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHostName 'Enter SSH hostname of backup machine'
  CreateApplicationMachineRestoreBackupScript "${sshUserName:?}" "${sshHostName:?}"
}

function AskBackupRestore () {
  Ask restoreBackup 'Restore backup (y/n)' 'n'
  if [[ "${restoreBackup?:}" == 'y' ]]; then
    InstallPackageIfNotExisting 'rsync'
    DisplayMessage 'Restoring backup...'
    DisplayMessage '(use "sudo journalctl --follow --unit server-setup-restore-backup.service" to see progress)'
    StartService 'server-setup-restore-backup'
    DisplayMessage 'Backup was successfully restored!'
  fi
}
