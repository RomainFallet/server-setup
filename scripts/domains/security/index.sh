#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/utilities.sh"

function SetUpSsh () {
  BackupSshConfigFile
  DisableSshPasswordAuthentication
  ConfigureSshKeepAlive
  WhiteListSshInFirewall
  RestartSsh
}

function SetUpFail2Ban () {
  InstallFail2Ban
  CreateFail2BanConfiguration
  RestartFail2Ban
}
