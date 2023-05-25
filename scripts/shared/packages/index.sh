#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/utilities.sh"

function InstallPackageIfNotExisting() {
  packageName="${1}"
  InstallAptPackageIfNotExisting "${packageName}"
}

function UpgradeAllPackages () {
  UpgradeAllAptPackages
}
