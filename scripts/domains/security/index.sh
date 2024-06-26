#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/utilities.sh"

function SetUpSsh () {
  BackupSshConfigFile
  RemoveOtherSshConfigFiles
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
  OpenSshFirewallPorts
  OpenHttpFirewallPorts
  EnableFireWall
}

function SetUpFileMachineFireWall () {
  OpenSshFirewallPorts
  OpenNfsFirewallPorts
  OpenSmbFirewallPorts
  EnableFireWall
}
