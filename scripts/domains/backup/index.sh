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

function SetUpFileMachineBackupScript () {
  AskIfNotSet sshFileMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshFileMachineHostName 'Enter SSH hostname of backup machine'
  AskIfNotSet fileMachineHealthCheckId 'Enter your HealthChecks.io monitoring ID'
  CreateFileMachineBackupScript "${sshFileMachineUserName:?}" "${sshFileMachineHostName:?}" "${fileMachineHealthCheckId:?}"
  CreateDailyCronJob 'file-backup' 'systemctl start file-backup.service'
}

function SetUpFileMachineRestoreBackupScript () {
  AskIfNotSet sshFileMachineUserName 'Enter SSH username of backup machine'
  AskIfNotSet sshFileMachineHostName 'Enter SSH hostname of backup machine'
  CreateFileMachineRestoreBackupScript "${sshFileMachineUserName:?}" "${sshFileMachineHostName:?}"
}

function AskMailMachineBackupRestore () {
  Ask restoreMailBackup 'Restore mail data (y/n)' 'n'
  if [[ "${restoreMailBackup?:}" == 'y' ]]; then
    DisplayMessage 'Restoring mailsdata...'
    ExecShellScriptWithRoot /var/opt/server-setup ./mail-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function AskApplicationMachineBackupRestore () {
  Ask restoreApplicationBackup 'Restore application data (y/n)' 'n'
  if [[ "${restoreApplicationBackup?:}" == 'y' ]]; then
    DisplayMessage 'Restoring applications data...'
    ExecShellScriptWithRoot /var/opt/server-setup ./application-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function AskHttpMachineBackupRestore () {
  Ask restoreHttpBackup 'Restore http data (y/n)' 'n'
  if [[ "${restoreHttpBackup?:}" == 'y' ]]; then
    DisplayMessage 'Restoring http data...'
    ExecShellScriptWithRoot /var/opt/server-setup ./http-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}

function AskFileMachineBackupRestore () {
  Ask restoreFileBackup 'Restore file data (y/n)' 'n'
  if [[ "${restoreFileBackup?:}" == 'y' ]]; then
    DisplayMessage 'Restoring file data...'
    ExecShellScriptWithRoot /var/opt/server-setup ./file-restore-backup.sh
    DisplayMessage 'Datas were successfully restored!'
  fi
}
