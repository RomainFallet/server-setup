#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
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
/usr/bin/rsync --archive --verbose --delete /etc/server-setup/ /home/user-data/server-setup
/usr/bin/rsync --archive --verbose --delete --progress /home/user-data/ ${sshUser}@${sshHostname}:~/data
systemctl start fix-mailinabox-permissions
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/mail-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'mail-backup' "/bin/bash ${filePath}" 'root'
}

function CreateMailMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data/ /home/user-data
systemctl start fix-mailinabox-permissions
/usr/bin/rsync --archive --verbose --delete /home/user-data/server-setup/ /etc/server-setup"
  filePath=/var/opt/server-setup/mail-restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'mail-restore-backup' "/bin/bash ${filePath}" 'root'
}

function CreateApplicationMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
rm -rf /root/data
mkdir -p /root/data
su --command \"pg_dumpall --clean --if-exists\" - postgres | sudo tee /root/data/pg_dump.sql > /dev/null
/usr/bin/rsync --archive --verbose --delete /etc/server-setup/ /root/data/server-setup
for directoryPath in /var/opt/*/
do
  directoryPath=\${directoryPath%*/}
  applicationName=\${directoryPath##*/}
  if [[ \"\${applicationName}\" == 'server-setup' ]]; then
    break
  fi
  mkdir -p /root/data/applications/\${applicationName}
  /usr/bin/rsync --archive --verbose --delete /var/opt/\${applicationName}/ /root/data/applications/\${applicationName}/opt
  /usr/bin/rsync --archive --verbose --delete /var/lib/\${applicationName}/ /root/data/applications/\${applicationName}/lib
  /usr/bin/rsync --archive --verbose --delete /etc/\${applicationName}/ /root/data/applications/\${applicationName}/etc
  /usr/bin/rsync --archive --verbose --delete /home/\${applicationName}/ /root/data/applications/\${applicationName}/home
  /usr/bin/rsync --archive --verbose --delete /etc/systemd/system/\${applicationName}.service /root/data/applications/\${applicationName}/systemd.service
done
/usr/bin/rsync --archive --verbose --delete /root/data/ ${sshUser}@${sshHostname}:~/data
rm -rf /root/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/application-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'application-backup' "/bin/bash ${filePath}" 'root'
}

function CreateApplicationMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
rm -rf /root/data
mkdir -p /root/data
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data/ /root/data
cp /root/data/pg_dump.sql /var/lib/postgresql/pg_dump.sql
su --command \"psql --file /var/lib/postgresql/pg_dump.sql\" - postgres
rm -f /var/lib/postgresql/pg_dump.sql
for directoryPath in  /root/data/applications/*/
do
  directoryPath=\${directoryPath%*/}
  applicationName=\${directoryPath##*/}
  /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/opt/ /var/opt/\${applicationName}
  /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/lib/ /var/lib/\${applicationName}
  /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/etc/ /etc/\${applicationName}
  /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/home/ /home/\${applicationName}
  /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/systemd.service /etc/systemd/system/\${applicationName}.service
  if ! id \"\${applicationName}\" > /dev/null; then
    adduser --system --shell /bin/bash --group --disabled-password --home /home/\"\${applicationName}\" \"\${applicationName}\"
  fi
  chown -R \"\${applicationName}\":\"\${applicationName}\" /var/{lib,opt}/\"\${applicationName}\"
  systemctl daemon-reload
  systemctl restart \"\${applicationName}\".service
done
rm -rf /root/data"
  filePath=/var/opt/server-setup/application-restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'application-restore-backup' "/bin/bash ${filePath}" 'root'
}

function CreateHttpMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
rm -rf /root/data
mkdir -p /root/data
mkdir -p /root/data/nginx
mkdir -p /root/data/letsencrypt
/usr/bin/rsync --archive --verbose --delete /etc/server-setup/ /root/data/server-setup
/usr/bin/rsync --archive --verbose --delete /etc/nginx/ /root/data/nginx/etc
/usr/bin/rsync --archive --verbose --delete /var/log/nginx/ /root/data/nginx/log
/usr/bin/rsync --archive --verbose --delete /var/www/ /root/data/nginx/www
/usr/bin/rsync --archive --verbose --delete /etc/letsencrypt/ /root/data/letsencrypt/etc
/usr/bin/rsync --archive --verbose --delete --progress /root/data/ ${sshUser}@${sshHostname}:~/data
rm -rf /root/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/http-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'http-backup' "/bin/bash ${filePath}" 'root'
}

function CreateHttpMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
rm -rf /root/data
mkdir -p /root/data
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data/ /root/data
/usr/bin/rsync --archive --verbose --delete /root/data/server-setup/ /etc/server-setup
/usr/bin/rsync --archive --verbose --delete /root/data/nginx/etc/ /etc/nginx
/usr/bin/rsync --archive --verbose --delete /root/data/nginx/log/ /var/log/nginx
/usr/bin/rsync --archive --verbose --delete /root/data/nginx/www/ /var/www
/usr/bin/rsync --archive --verbose --delete /root/data/letsencrypt/etc/ /etc/letsencrypt
chown -R www-data:www-data /var/www
systemctl restart nginx
rm -rf /root/data"
  filePath=/var/opt/server-setup/http-restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'http-restore-backup' "/bin/bash ${filePath}" 'root'
}

function CreateFileMachineBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  healthChecksUuid="${3}"
  fileContent="#!/bin/bash
set -e
/usr/bin/rsync --archive --verbose --delete --progress /mnt/sda/ ${sshUser}@${sshHostname}:~/data
/usr/bin/curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
  filePath=/var/opt/server-setup/file-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'file-backup' "/bin/bash ${filePath}" 'root'
}

function CreateFileMachineRestoreBackupScript () {
  sshUser="${1}"
  sshHostname="${2}"
  fileContent="#!/bin/bash
set -e
/usr/bin/rsync --archive --verbose --delete ${sshUser}@${sshHostname}:~/data/ /mnt/sda"
  filePath=/var/opt/server-setup/file-restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'file-restore-backup' "/bin/bash ${filePath}" 'root'
}
