#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/cron/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/shell/index.sh"

function SetUpMailMachineBackupScript () {
  AskIfNotSet configureMailMachineBackup 'Configure backups? (y/n)' 'y'
  if [[ "${configureMailMachineBackup?:}" == 'y' ]]; then
    AskIfNotSet sshMailMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshMailMachineHostName 'Enter SSH hostname of backup machine'
    AskIfNotSet mailMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
    CreateMailMachineBackupScript "${sshMailMachineUserName:?}" "${sshMailMachineHostName:?}" "${mailMachineHealthCheckId:?}"
    CreateDailyCronJob 'mail-backup' 'systemctl start mail-backup.service'
  fi
}

function SetUpMailMachineRestoreBackupScript () {
  Ask restoreMailBackup 'Restore mail data (y/n)' 'n'
  if [[ "${restoreMailBackup?:}" == 'y' ]]; then
    AskIfNotSet sshMailMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshMailMachineHostName 'Enter SSH hostname of backup machine'
    CreateMailMachineRestoreBackupScript "${sshMailMachineUserName:?}" "${sshMailMachineHostName:?}"
    DisplayMessage 'Restoring mailsdata...'
    ExecShellScriptWithRoot /var/opt/server-setup ./mail-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function SetUpApplicationMachineBackupScript () {
  AskIfNotSet configureApplicationMachineBackup 'Configure backups? (y/n)' 'y'
  if [[ "${configureApplicationMachineBackup?:}" == 'y' ]]; then
    AskIfNotSet sshApplicationMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshApplicationMachineHostName 'Enter SSH hostname of backup machine'
    AskIfNotSet applicationMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
    CreateApplicationMachineBackupScript "${sshApplicationMachineUserName:?}" "${sshApplicationMachineHostName:?}" "${applicationMachineHealthCheckId:?}"
    CreateDailyCronJob 'application-backup' 'systemctl start application-backup.service'
  fi
}

function SetUpApplicationMachineRestoreBackupScript () {
  Ask restoreApplicationBackup 'Restore application data (y/n)' 'n'
  if [[ "${restoreApplicationBackup?:}" == 'y' ]]; then
    AskIfNotSet sshApplicationMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshApplicationMachineHostName 'Enter SSH hostname of backup machine'
    CreateApplicationMachineRestoreBackupScript "${sshApplicationMachineUserName:?}" "${sshApplicationMachineHostName:?}"
    DisplayMessage 'Restoring applications data...'
    ExecShellScriptWithRoot /var/opt/server-setup ./application-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function SetUpHttpMachineBackupScript () {
  AskIfNotSet configureHttpMachineBackup 'Configure backups? (y/n)' 'y'
  if [[ "${configureHttpMachineBackup?:}" == 'y' ]]; then
    AskIfNotSet sshHttpMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshHttpMachineHostName 'Enter SSH hostname of backup machine'
    AskIfNotSet httpMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
    CreateHttpMachineBackupScript "${sshHttpMachineUserName:?}" "${sshHttpMachineHostName:?}" "${httpMachineHealthCheckId:?}"
    CreateDailyCronJob 'http-backup' 'systemctl start http-backup.service'*
  fi
}

function SetUpHttpMachineRestoreBackupScript () {
  Ask restoreHttpBackup 'Restore http data (y/n)' 'n'
  if [[ "${restoreHttpBackup?:}" == 'y' ]]; then
    AskIfNotSet sshHttpMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshHttpMachineHostName 'Enter SSH hostname of backup machine'
    CreateHttpMachineRestoreBackupScript "${sshHttpMachineUserName:?}" "${sshHttpMachineHostName:?}"
    DisplayMessage 'Restoring http data...'
    ExecShellScriptWithRoot /var/opt/server-setup ./http-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function SetUpFileMachineBackupScript () {
  AskIfNotSet configureFileMachineBackup 'Configure backups? (y/n)' 'y'
  if [[ "${configureFileMachineBackup?:}" == 'y' ]]; then
    AskIfNotSet sshFileMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshFileMachineHostName 'Enter SSH hostname of backup machine'
    AskIfNotSet fileMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
    CreateFileMachineBackupScript "${sshFileMachineUserName:?}" "${sshFileMachineHostName:?}" "${fileMachineHealthCheckId:?}"
    CreateDailyCronJob 'file-backup' 'systemctl start file-backup.service'
  fi
}

function SetUpFileMachineRestoreBackupScript () {
  Ask restoreFileBackup 'Restore file data (y/n)' 'n'
  if [[ "${restoreFileBackup?:}" == 'y' ]]; then
    AskIfNotSet sshFileMachineUserName 'Enter SSH username of backup machine'
    AskIfNotSet sshFileMachineHostName 'Enter SSH hostname of backup machine'
    CreateFileMachineRestoreBackupScript "${sshFileMachineUserName:?}" "${sshFileMachineHostName:?}"
    DisplayMessage 'Restoring file data...'
    ExecShellScriptWithRoot /var/opt/server-setup ./file-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}
