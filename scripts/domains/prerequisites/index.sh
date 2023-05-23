#!/bin/bash

# shellcheck source=../../shared/packages/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"

function SetUpHostingMachinePrerequisites () {
  InstallPackageIfNotExisting 'postgresql'
  InstallPackageIfNotExisting 'jq'
  InstallPackageIfNotExisting 'nginx'
  InstallPackageIfNotExisting 'certbot'
}
