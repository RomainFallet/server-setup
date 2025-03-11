#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/firewall/index.sh"

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
logpath = /var/log/auth.log"
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

function OpenSshFirewallPorts () {
  OpenFireWallPort '22'
}

function OpenHttpFirewallPorts () {
  OpenFireWallPort '80'
  OpenFireWallPort '443'
}

function OpenNfsFirewallPorts () {
  OpenFireWallPort '2049'
  OpenFireWallPort '111'
  OpenFireWallPort '892'
  OpenFireWallPort '32803'
  OpenFireWallPort '32769'
  OpenFireWallPort '662'
}

function OpenSmbFirewallPorts () {
  OpenFireWallPort '137'
  OpenFireWallPort '138'
  OpenFireWallPort '139'
  OpenFireWallPort '445'
}

function OpenEmbyPorts () {
  OpenFireWallPort '8096'
}
