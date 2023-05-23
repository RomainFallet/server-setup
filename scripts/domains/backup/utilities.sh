#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/cron/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/firewall/index.sh"
# shellcheck source-path=../../../
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
  if [[ "${restoreBackup?:}" == 'y' ]]; then
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
/usr/bin/rsync -av --delete --progress /root/data/ ${sshUser}@${sshHostname}:~/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-backup' "/bin/bash ${filePath}" 'root'
}

function CreateHostingMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
sudo ufw disallow 443/tcp
sudo ufw disallow 80/tcp
/usr/bin/rsync -av --delete ${sshUser}@${sshHostname}:~/data /root/data
cp --archive /root/data/nginx /etc/
cp --archive /root/data/letsencrypt /etc/
cp --archive /root/data/systemd /etc/
cp --archive /root/data/server-setup /etc/
cp --archive /root/data/www /var/
cp --archive /root/data/log /var/
cp --archive /root/data/lib /var/
cp --archive /root/data/opt /var/
cp --archive /root/data/home /
for dir in /var/opt/*/
do
    dir=\${dir%*/}
    echo \${dir##*/}
done
su --command \"psql --file /root/data/pg_dump.sql\" - postgres
sudo systemctl daemon-reload
sudo systemctl restart nginx
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp"
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
