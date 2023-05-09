#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source=../../shared/services/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source=../../shared/cron/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/cron/index.sh"

function CreateBackupScript () {
  sourcePath="${1}"
  sshUser="${2}"
  sshHostname="${3}"
  destinationPath="${4}"
  healthChecksUuid="${5}"
  fileContent="#!/bin/bash
set -e
/usr/bin/rsync -av --delete --progress ${sourcePath} ${sshUser}@${sshHostname}:${destinationPath}
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/opt/server-setup/backup.sh
  CreateDirectoryIfNotExists "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateSystemdService 'server-setup-backup' '/bin/bash /opt/server-setup/backup.sh' 'root'
}

function CreateRestoreBackupScript () {
  sourcePath="${1}"
  sshUser="${2}"
  sshHostname="${3}"
  destinationPath="${4}"
  fileContent="#!/bin/bash
set -e
/usr/bin/rsync -av --delete ${sshUser}@${sshHostname}:${sourcePath} ${destinationPath}"
  filePath=/opt/server-setup/restore-backup.sh
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateSystemdService 'server-setup-restore-backup' '/bin/bash /opt/server-setup/restore-backup.sh' 'root'
}

function CreateDailyBackupCronJob () {
  CreateDailyCronJob 'server-setup-backup' 'systemctl start server-setup-backup.service'
}

function CreateWeeklyBackupCronJob () {
  CreateWeeklyCronJob 'server-setup-backup' 'systemctl start server-setup-backup.service'
}
