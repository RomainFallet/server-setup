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
/usr/bin/rsync --archive --verbose --delete /etc/server-setup /home/user-data/server-setup
/usr/bin/rsync --archive --verbose --delete --progress /home/user-data/ ${sshUser}@${sshHostname}:~/data
systemctl start fix-mailinabox-permissions
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
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data/ /home/user-data
systemctl start fix-mailinabox-permissions
/usr/bin/rsync --archive --verbose --delete /home/user-data/server-setup /etc/server-setup"
  filePath=/var/opt/server-setup/restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-restore-backup' "/bin/bash ${filePath}" 'root'
}

function CreateApplicationMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
mkdir -p /root/data
su --command \"pg_dumpall --clean --if-exists\" - postgres | sudo tee /root/data/pg_dump.sql > /dev/null
/usr/bin/rsync --archive --verbose --delete /etc/systemd /root/data/systemd
/usr/bin/rsync --archive --verbose --delete /etc/server-setup /root/data/server-setup
/usr/bin/rsync --archive --verbose --delete /var/log /root/data/log
/usr/bin/rsync --archive --verbose --delete /var/lib /root/data/lib
/usr/bin/rsync --archive --verbose --delete /var/opt /root/data/opt
/usr/bin/rsync --archive --verbose --delete /home /root/data/home
/usr/bin/rsync --archive --verbose --delete /root/data/ ${sshUser}@${sshHostname}:~/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-backup' "/bin/bash ${filePath}" 'root'
}

function CreateApplicationMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
sudo ufw disallow 443/tcp
sudo ufw disallow 80/tcp
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data /root/data
su --command \"psql --file /root/data/pg_dump.sql\" - postgres
/usr/bin/rsync --archive --verbose --delete /root/data/systemd /etc/systemd
/usr/bin/rsync --archive --verbose --delete /root/data/server-setup /etc/server-setup
/usr/bin/rsync --archive --verbose --delete /root/data/log /var/log
/usr/bin/rsync --archive --verbose --delete /root/data/lib /var/lib
/usr/bin/rsync --archive --verbose --delete /root/data/opt /var/opt
/usr/bin/rsync --archive --verbose --delete /root/data/home /home
systemctl daemon-reload
do
  directoryName=\${directoryName%*/}
  applicationUsername=\${directoryName##*/}
  if ! id \"\${applicationUsername}\" > /dev/null; then
    adduser --system --shell /bin/bash --group --disabled-password --home /home/\"\${applicationUsername}\" \"\${applicationUsername}\"
  fi
  chown -R \"\${applicationUsername}\":\"\${applicationUsername}\" /var/{lib,opt}/\"\${applicationUsername}\"
  systemctl restart \"\${applicationUsername}\".service
done
sudo ufw allow 443/tcp
sudo ufw allow 80/tcp"
  filePath=/var/opt/server-setup/restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-restore-backup' "/bin/bash ${filePath}" 'root'
}


function CreateHttpMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
mkdir -p /root/data
/usr/bin/rsync --archive --verbose --delete /etc/nginx /root/data/nginx
/usr/bin/rsync --archive --verbose --delete /etc/letsencrypt /root/data/letsencrypt
/usr/bin/rsync --archive --verbose --delete /etc/server-setup /root/data/server-setup
/usr/bin/rsync --archive --verbose --delete /var/www /root/data/www
/usr/bin/rsync --archive --verbose --delete /var/log /root/data/log
/usr/bin/rsync --archive --verbose --delete /home /root/data/home
/usr/bin/rsync --archive --verbose --delete --progress /root/data/ ${sshUser}@${sshHostname}:~/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'server-setup-backup' "/bin/bash ${filePath}" 'root'
}

function CreateHttpMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
sudo ufw disallow 443/tcp
sudo ufw disallow 80/tcp
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data /root/data
/usr/bin/rsync --archive --verbose --delete /root/data/nginx /etc/nginx
/usr/bin/rsync --archive --verbose --delete /root/data/letsencrypt /etc/letsencrypt
/usr/bin/rsync --archive --verbose --delete /root/data/server-setup /etc/letsencrypt
/usr/bin/rsync --archive --verbose --delete /root/data/www /var/www
/usr/bin/rsync --archive --verbose --delete /root/data/log /var/log
/usr/bin/rsync --archive --verbose --delete /root/data/home /home
systemctl daemon-reload
systemctl restart nginx
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
