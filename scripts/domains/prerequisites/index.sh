#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/devices/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/logs/index.sh"

function SetUpApplicationMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'postgresql'
  InstallPackageIfNotExisting 'jq'
}

function SetUpHttpMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'nginx'
  InstallPackageIfNotExisting 'certbot'
}

function SetUpBackupMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
  InstallPackageIfNotExisting 'rsync'
  if [[ "${useExternalHardDrive:?}" == 'y' ]]; then
    MountDeviceAutomaticallyIfConnected 'sda'
  fi
}

function SetUpFileMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'nfs-kernel-server'
  MountDeviceAutomaticallyIfConnected 'sda'
}

