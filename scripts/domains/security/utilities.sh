#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source=../../shared/packages/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source=../../shared/services/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source=../../shared/firewall/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/firewall/index.sh"

function InstallFail2Ban () {
  InstallAptPackageIfNotExisting 'fail2ban'
}

function CreateFail2BanConfiguration () {
  fileContent="[DEFAULT]
findtime = 3600
bantime = 86400

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3"
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

function WhiteListSshInFirewall () {
  OpenFireWallPort '22'
}

function BackupSshConfigFile () {
  BackupFile /etc/ssh/sshd_config
}