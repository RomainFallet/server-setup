#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

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
  sudo service ssh restart
}

function WhiteListSshInFirewall () {
  sudo ufw allow ssh
}

function BackupSshConfigFile () {
  BackupFile /etc/ssh/sshd_config
}
