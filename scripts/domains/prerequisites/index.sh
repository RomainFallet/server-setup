#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"

function SetUpHostingMachinePrerequisites () {
  InstallPackageIfNotExisting 'postgresql'
  InstallPackageIfNotExisting 'jq'
  InstallPackageIfNotExisting 'nginx'
  InstallPackageIfNotExisting 'certbot'
}
