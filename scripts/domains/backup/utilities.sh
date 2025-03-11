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
mkdir -p /root/data/nginx
mkdir -p /root/data/letsencrypt
/usr/bin/rsync --archive --verbose --delete /etc/server-setup/ /root/data/server-setup
/usr/bin/rsync --archive --verbose --delete /etc/nginx/ /root/data/nginx/etc
/usr/bin/rsync --archive --verbose --delete /var/log/nginx/ /root/data/nginx/log
/usr/bin/rsync --archive --verbose --delete /var/www/ /root/data/nginx/www
/usr/bin/rsync --archive --verbose --delete /etc/letsencrypt/ /root/data/letsencrypt/etc
su --command \"pg_dumpall --clean --if-exists\" - postgres | sudo tee /root/data/pg_dump.sql > /dev/null
/usr/bin/rsync --archive --verbose --delete /etc/server-setup/ /root/data/server-setup
for directoryPath in /var/opt/*/
do
  directoryPath=\${directoryPath%*/}
  applicationName=\${directoryPath##*/}
  mkdir -p /root/data/applications/\${applicationName}
  if [[ \"\${applicationName}\" == 'server-setup' ]]; then
    continue
  fi
  echo \"Backing up \${applicationName}...\"
  if test -d /var/opt/\${applicationName}/; then
    mkdir -p /root/data/applications/\${applicationName}/opt
    /usr/bin/rsync --archive --verbose --delete /var/opt/\${applicationName}/ /root/data/applications/\${applicationName}/opt
    echo \"Moved /var/opt/\${applicationName}/ to /root/data/applications/\${applicationName}/opt\"
  fi
  if test -d /var/lib/\${applicationName}/; then
    mkdir -p /root/data/applications/\${applicationName}/lib
    /usr/bin/rsync --archive --verbose --delete /var/lib/\${applicationName}/ /root/data/applications/\${applicationName}/lib
    echo \"Moved /var/lib/\${applicationName}/ to /root/data/applications/\${applicationName}/lib\"
  fi
  if test -d /etc/\${applicationName}/; then
    mkdir -p /root/data/applications/\${applicationName}/etc
    /usr/bin/rsync --archive --verbose --delete /etc/\${applicationName}/ /root/data/applications/\${applicationName}/etc
    echo \"Moved /etc/\${applicationName}/ to /root/data/applications/\${applicationName}/etc\"
  fi
  if test -d /home/\${applicationName}/; then
    mkdir -p /root/data/applications/\${applicationName}/home
    /usr/bin/rsync --archive --verbose --delete /home/\${applicationName}/ /root/data/applications/\${applicationName}/home
    echo \"Moved /home/\${applicationName}/ to /root/data/applications/\${applicationName}/home\"
  fi
  if test -f /etc/systemd/system/\${applicationName}.service; then
    /usr/bin/rsync --archive --verbose --delete /etc/systemd/system/\${applicationName}.service /root/data/applications/\${applicationName}/systemd.service
    echo \"Moved /etc/systemd/system/\${applicationName}.service to /root/data/applications/\${applicationName}/systemd.service\"
  fi
  if test -f /etc/systemd/system/\${applicationName}-port-forwarding.service; then
    /usr/bin/rsync --archive --verbose --delete /etc/systemd/system/\${applicationName}-port-forwarding.service /root/data/applications/\${applicationName}/systemd-port-forwarding.service
    echo \"Moved /etc/systemd/system/\${applicationName}-port-forwarding.service to /root/data/applications/\${applicationName}/systemd-port-forwarding.service\"
  fi
  if test -f /etc/systemd/system/\${applicationName}-watcher.service > /dev/null; then
    /usr/bin/rsync --archive --verbose --delete /etc/systemd/system/\${applicationName}-watcher.service /root/data/applications/\${applicationName}/systemd-watcher.service
    echo \"Moved /etc/systemd/system/\${applicationName}-watcher.service to /root/data/applications/\${applicationName}/systemd-watcher.service\"
  fi
  if test -f /etc/systemd/system/\${applicationName}-watcher.path > /dev/null; then
    /usr/bin/rsync --archive --verbose --delete /etc/systemd/system/\${applicationName}-watcher.path /root/data/applications/\${applicationName}/systemd-watcher.path
    echo \"Moved /etc/systemd/system/\${applicationName}-watcher.path to /root/data/applications/\${applicationName}/systemd-watcher.path\"
  fi
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
/usr/bin/rsync --archive --verbose --delete /root/data/server-setup/ /etc/server-setup
/usr/bin/rsync --archive --verbose --delete /root/data/nginx/etc/ /etc/nginx
/usr/bin/rsync --archive --verbose --delete /root/data/nginx/log/ /var/log/nginx
/usr/bin/rsync --archive --verbose --delete /root/data/nginx/www/ /var/www
/usr/bin/rsync --archive --verbose --delete /root/data/letsencrypt/etc/ /etc/letsencrypt
chown -R www-data:www-data /var/www
systemctl restart nginx
cp /root/data/pg_dump.sql /var/lib/postgresql/pg_dump.sql
su --command \"psql --file /var/lib/postgresql/pg_dump.sql\" - postgres
rm -f /var/lib/postgresql/pg_dump.sql
/usr/bin/rsync --archive --verbose --delete /root/data/server-setup/ /etc/server-setup
for directoryPath in  /root/data/applications/*/
do
  directoryPath=\${directoryPath%*/}
  applicationName=\${directoryPath##*/}
  if [[ \"\${applicationName}\" == 'server-setup' ]]; then
    continue
  fi
  echo \"Restoring \${applicationName}...\"
  if ! id \"\${applicationName}\" > /dev/null; then
    adduser --system --shell /bin/bash --group --disabled-password --home /home/\"\${applicationName}\" \"\${applicationName}\"
  fi
  if test -d /root/data/applications/\${applicationName}/opt/; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/opt/ /var/opt/\${applicationName}
    chown -R \"\${applicationName}\":\"\${applicationName}\" \"/var/opt/\${applicationName}\"
    echo \"Moved /root/data/applications/\${applicationName}/opt/ to /var/opt/\${applicationName}\"
  fi
  if test -d /root/data/applications/\${applicationName}/lib/; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/lib/ /var/lib/\${applicationName}
    chown -R \"\${applicationName}\":\"\${applicationName}\" \"/var/lib/\${applicationName}\"
    echo \"Moved /root/data/applications/\${applicationName}/lib/ to /var/lib/\${applicationName}\"
  fi
  if test -d /root/data/applications/\${applicationName}/etc/; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/etc/ /etc/\${applicationName}
    chown -R \"\${applicationName}\":\"\${applicationName}\" \"/etc/\${applicationName}\"
    echo \"Moved /root/data/applications/\${applicationName}/etc/ to /etc/\${applicationName}\"
  fi
  if test -d /root/data/applications/\${applicationName}/home/; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/home/ /home/\${applicationName}
    chown -R \"\${applicationName}\":\"\${applicationName}\" \"/home/\${applicationName}\"
    echo \"Moved /root/data/applications/\${applicationName}/home/ to /home/\${applicationName}\"
  fi
  if test -f /root/data/applications/\${applicationName}/systemd.service; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/systemd.service /etc/systemd/system/\${applicationName}.service
    echo \"Moved /root/data/applications/\${applicationName}/systemd.service to /etc/systemd/system/\${applicationName}.service\"
  fi
  if test -f /root/data/applications/\${applicationName}/systemd-port-forwarding.service; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/systemd-port-forwarding.service /etc/systemd/system/\${applicationName}-port-forwarding.service
    echo \"Moved /root/data/applications/\${applicationName}/systemd-port-forwarding.service to /etc/systemd/system/\${applicationName}-port-forwarding.service\"
  fi
  if test -f /root/data/applications/\${applicationName}/systemd-watcher.service > /dev/null; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/systemd-watcher.service /etc/systemd/system/\${applicationName}-watcher.service
    echo \"Moved /root/data/applications/\${applicationName}/systemd-watcher.service to /etc/systemd/system/\${applicationName}-watcher.service\"
  fi
  if test -f /root/data/applications/\${applicationName}/systemd-watcher.path > /dev/null; then
    /usr/bin/rsync --archive --verbose --delete /root/data/applications/\${applicationName}/systemd-watcher.path /etc/systemd/system/\${applicationName}-watcher.path
    echo \"Moved /root/data/applications/\${applicationName}/systemd-watcher.path to /etc/systemd/system/\${applicationName}-watcher.path\"
  fi
  systemctl daemon-reload
  systemctl restart \"\${applicationName}.service\"
  if test -f /etc/systemd/system/\${applicationName}-port-forwarding.service > /dev/null; then
    systemctl restart \"\${applicationName}-port-forwarding.service\"
  fi
  if test -f /etc/systemd/system/\${applicationName}-watcher.path > /dev/null; then
    systemctl restart \"\${applicationName}-watcher.path\"
  fi
  if test -f /etc/systemd/system/\${applicationName}-watcher.service > /dev/null; then
    systemctl restart \"\${applicationName}-watcher.service\"
  fi
done
rm -rf /root/data"
  filePath=/var/opt/server-setup/application-restore-backup.sh
  CreateDirectoryIfNotExisting "$(dirname "${filePath}")"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
  CreateService 'application-restore-backup' "/bin/bash ${filePath}" 'root'
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
