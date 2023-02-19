#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/ssh/utilities.sh"

function SetUpSsh () {
  BackupSshConfigFile
  DisableSshPasswordAuthentication
  ConfigureSshKeepAlive
  WhiteListSshInFirewall
  RestartSsh
}

export -f SetUpSsh
