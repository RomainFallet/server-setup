#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/cron/index.sh"


function SetUpMailMachineBackupScript () {
  AskIfNotSet sshMailMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshMailMachineHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet mailMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
  CreateMailMachineBackupScript "${sshMailMachineUserName:?}" "${sshMailMachineHostName:?}" "${mailMachineHealthCheckId:?}"
  CreateDailyCronJob 'mail-backup' 'systemctl start mail-backup.service'
}

function SetUpMailMachineRestoreBackupScript () {
  AskIfNotSet sshMailMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshMailMachineHostName 'Enter SSH hostname of backup machine'
  CreateMailMachineRestoreBackupScript "${sshMailMachineUserName:?}" "${sshMailMachineHostName:?}"
}

function SetUpApplicationMachineBackupScript () {
  AskIfNotSet sshApplicationMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshApplicationMachineHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet applicationMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
  CreateApplicationMachineBackupScript "${sshApplicationMachineUserName:?}" "${sshApplicationMachineHostName:?}" "${applicationMachineHealthCheckId:?}"
  CreateDailyCronJob 'application-backup' 'systemctl start application-backup.service'
}

function SetUpApplicationMachineRestoreBackupScript () {
  AskIfNotSet sshApplicationMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshApplicationMachineHostName 'Enter SSH hostname of backup machine'
  CreateApplicationMachineRestoreBackupScript "${sshApplicationMachineUserName:?}" "${sshApplicationMachineHostName:?}"
}

function SetUpHttpMachineBackupScript () {
  AskIfNotSet sshHttpMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHttpMachineHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet httpMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
  CreateHttpMachineBackupScript "${sshHttpMachineUserName:?}" "${sshHttpMachineHostName:?}" "${httpMachineHealthCheckId:?}"
  CreateDailyCronJob 'http-backup' 'systemctl start http-backup.service'
}

function SetUpHttpMachineRestoreBackupScript () {
  AskIfNotSet sshHttpMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshHttpMachineHostName 'Enter SSH hostname of backup machine'
  CreateHttpMachineRestoreBackupScript "${sshHttpMachineUserName:?}" "${sshHttpMachineHostName:?}"
}

function AskMailMachineBackupRestore () {
  Ask restoreMailBackup 'Restore mail data (y/n)' 'n'
  if [[ "${restoreMailBackup?:}" == 'y' ]]; then
    InstallPackageIfNotExisting 'rsync'
    DisplayMessage 'Restoring mailsdata...'
    DisplayMessage '(use "sudo journalctl --follow --unit mail-restore-backup.service" to see progress)'
    StartService 'mail-restore-backup'
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function AskApplicationMachineBackupRestore () {
  Ask restoreApplicationBackup 'Restore application data (y/n)' 'n'
  if [[ "${restoreApplicationBackup?:}" == 'y' ]]; then
    InstallPackageIfNotExisting 'rsync'
    DisplayMessage 'Restoring applications data...'
    DisplayMessage '(use "sudo journalctl --follow --unit application-restore-backup.service" to see progress)'
    StartService 'application-restore-backup'
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function AskHttpMachineBackupRestore () {
  Ask restoreHttpBackup 'Restore http data (y/n)' 'n'
  if [[ "${restoreHttpBackup?:}" == 'y' ]]; then
    InstallPackageIfNotExisting 'rsync'
    DisplayMessage 'Restoring http data...'
    DisplayMessage '(use "sudo journalctl --follow --unit http-restore-backup.service" to see progress)'
    StartService 'http-restore-backup'
    DisplayMessage 'Datas were successfully restored!'
  fi
}
