#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/file-sharing/utilities.sh"

function SetUpFileSharing () {
  ConfigureNfs
  ConfigureSamba
  ConfigureFolders
  ExportFolders
  RestartNfs
  RestartSamba
}
