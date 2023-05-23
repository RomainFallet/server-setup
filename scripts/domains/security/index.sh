#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/firewall/index.sh"

function SetUpSsh () {
  BackupSshConfigFile
  DisableSshPasswordAuthentication
  ConfigureSshKeepAlive
  RestartSsh
}

function SetUpFail2Ban () {
  InstallFail2Ban
  CreateFail2BanConfiguration
  RestartFail2Ban
}

function SetUpMachineFireWall () {
  OpenFireWallPort '22'
  OpenFireWallPort '443'
  OpenFireWallPort '80'
  EnableFireWall
}
