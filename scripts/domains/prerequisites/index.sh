#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/devices/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/logs/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/prerequisites/utilities.sh"

function SetUpApplicationMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'postgresql'
  InstallPackageIfNotExisting 'jq'
  InstallPackageIfNotExisting 'autossh'
}

function SetUpWebMachinePrerequisites () {
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
  InstallPackageIfNotExisting 'samba'
  MountDeviceAutomaticallyIfConnected 'sda'
}

function SetUpCiMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
  InstallDocker
}

function SetUpCiRunnerMachinePrerequisites () {
  UpgradeAllPackages
  CleanOldLogs
}
