#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/devices/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SetUpApplicationMachinePrerequisites () {
  UpgradeAllPackages
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'postgresql'
  InstallPackageIfNotExisting 'openjdk-17-jre'
  InstallPackageIfNotExisting 'jq'
}

function SetUpHttpMachinePrerequisites () {
  UpgradeAllPackages
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'nginx'
  InstallPackageIfNotExisting 'certbot'
}

function SetUpBackupMachinePrerequisites () {
  UpgradeAllPackages
  InstallPackageIfNotExisting 'rsync'
  if [[ "${useExternalHardDrive:?}" == 'y' ]]; then
    MountDeviceAutomaticallyIfConnected 'sda'
  fi
}

function SetUpFileMachinePrerequisites () {
  UpgradeAllPackages
  InstallPackageIfNotExisting 'rsync'
  InstallPackageIfNotExisting 'nfs-kernel-server'
  MountDeviceAutomaticallyIfConnected 'sda'
}

