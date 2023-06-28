#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"

function InstallFail2Ban () {
  InstallPackageIfNotExisting 'fail2ban'
}

function CreateFail2BanConfiguration () {
  fileContent="[DEFAULT]
findtime = 3600
bantime = 86400
maxretry = 10

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log

[nginx-req-limit]
enabled = true
filter = nginx-req-limit
action = iptables-multiport[name=ReqLimit, port=\"http,https\", protocol=tcp]
logpath = /var/log/nginx/*error.log

[nginx-http-auth]
enabled  = true
port     = http,https
filter   = nginx-http-auth
logpath  = /var/log/nginx/*error.log"
  filePath=/etc/fail2ban/jail.local
  SetFileContent "${fileContent}" "${filePath}"
}

function RestartFail2Ban () {
  RestartService 'fail2ban'
}

function DisableSshPasswordAuthentication () {
  passwordConfiguration='PasswordAuthentication no'
  ReplaceTextInFile '#*PasswordAuthentication\s+\w+' "${passwordConfiguration}" /etc/ssh/sshd_config
  AppendTextInFileIfNotFound "${passwordConfiguration}" /etc/ssh/sshd_config
}

function ConfigureSshKeepAlive () {
  clientAliveIntervalConfiguration='ClientAliveInterval 60'
  ReplaceTextInFile '#*ClientAliveInterval\s+[0-9]+' "${clientAliveIntervalConfiguration}" /etc/ssh/sshd_config
  AppendTextInFileIfNotFound "${clientAliveIntervalConfiguration}" /etc/ssh/sshd_config

  clientAliveCountConfiguration='ClientAliveCountMax 10'
  ReplaceTextInFile '#*ClientAliveCountMax\s+[0-9]+' "${clientAliveCountConfiguration}" /etc/ssh/sshd_config
  AppendTextInFileIfNotFound "${clientAliveCountConfiguration}" /etc/ssh/sshd_config
}

function RestartSsh () {
  RestartService 'ssh'
}

function BackupSshConfigFile () {
  BackupFile /etc/ssh/sshd_config
}

function RemoveOtherSshConfigFiles () {
  RemoveFile /etc/ssh/sshd_config.d/50-cloud-init.conf
}
