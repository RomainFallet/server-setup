#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/emby/utilities.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SetupEmby () {
  embyDownloadPath=/tmp/emby.deb
  embyLatestVersion=$(GetLatestEmbyVersion)
  echo "Emby latest version: ${embyLatestVersion}"
  DownloadEmby "${embyDownloadPath}" "${embyLatestVersion}"
  InstallAptPackageFromFile "${embyDownloadPath}"
}
