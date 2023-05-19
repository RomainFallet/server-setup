#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source=../../shared/services/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source=../../shared/cron/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/cron/index.sh"
# shellcheck source=../../shared/firewall/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/firewall/index.sh"
# shellcheck source=../../shared/packages/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"

function CreateMailMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
cp --archive /etc/server-setup /home/user-data/
/usr/bin/rsync -av --delete --progress /home/user-data/ ${sshUser}@${sshHostname}:~/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-backup' "/bin/bash ${filePath}" 'root'
}

function CreateMailMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
/usr/bin/rsync -av --delete ${sshUser}@${sshHostname}:~/data /home/user-data
cp --archive /home/user-data/server-setup /etc/"
  filePath=/var/opt/server-setup/restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-restore-backup' "/bin/bash ${filePath}" 'root'
}

function RestoreMailMachineBackupScript () {
  AskIfNotSet restoreBackup 'Restore backup (y/n)' 'n'
  if [[ "${restoreBackup}" == 'y' ]]; then
      InstallPackageIfNotExisting 'rsync'
      StartService 'server-setup-restore-backup'
      FollowServiceLogs 'server-setup-restore-backup'
  fi
}

function CreateHostingMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
mkdir -p /root/data
su --command \"pg_dumpall --clean --if-exists\" - postgres | sudo tee /root/data/pg_dump.sql > /dev/null
cp --archive /etc/nginx /root/data/
cp --archive /etc/letsencrypt /root/data/
cp --archive /etc/systemd /root/data/
cp --archive /etc/server-setup /root/data/
cp --archive /var/www /root/data/
cp --archive /var/log /root/data/
cp --archive /var/lib /root/data/
cp --archive /var/opt /root/data/
cp --archive /home /root/data/
awk -F: '($3>=1000) && ($3<=29999)' /etc/passwd | tee /root/data/passwd.bak > /dev/null
awk -F: '($3>=1000) && ($3<=29999)' /etc/group | tee /root/data/group.bak > /dev/null
awk -F: '($3>=1000) && ($3<=29999) {print $1}' /etc/passwd | tee - |egrep -f - /etc/shadow | tee /root/data/shadow.back > /dev/null
/usr/bin/rsync -av --delete --progress /root/data/ ${sshUser}@${sshHostname}:~/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-backup' "/bin/bash ${filePath}" 'root'
}

function CreateHostingMachineRestoreBackupScript () {
  sourcePath="${1}"
  sshUser="${2}"
  sshHostname="${3}"
  destinationPath="${4}"
  fileContent="#!/bin/bash
set -e
sudo ufw disallow 443/tcp
sudo ufw disallow 80/tcp
/usr/bin/rsync -av --delete ${sshUser}@${sshHostname}:${sourcePath} ${destinationPath}

sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp
"
  filePath=/var/opt/server-setup/restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-restore-backup' "/bin/bash ${filePath}" 'root'
}

function CreateDailyBackupCronJob () {
  CreateDailyCronJob 'server-setup-backup' 'systemctl start server-setup-backup.service'
}

function CreateWeeklyBackupCronJob () {
  CreateWeeklyCronJob 'server-setup-backup' 'systemctl start server-setup-backup.service'
}
