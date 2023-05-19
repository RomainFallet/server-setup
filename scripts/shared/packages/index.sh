#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/utilities.sh"

function InstallPackageIfNotExisting() {
  packageName="${1}"
  InstallAptPackageIfNotExisting "${packageName}"
}
