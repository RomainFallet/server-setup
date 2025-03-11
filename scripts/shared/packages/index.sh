#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/utilities.sh"

function InstallPackageIfNotExisting() {
  packageName="${1}"
  InstallAptPackageIfNotExisting "${packageName}"
}

function InstallPackageFromFile() {
  packagePath="${1}"
  InstallAptPackageFromFile "${packagePath}"
}


function UpgradeAllPackages () {
  UpgradeAllAptPackages
}


function AddGpgKey () {
  keyDownloadUrl="${1}"
  keyPath="${2}"
  RemoveFile "${keyPath}"
  AddGpgKeyWithCurl "${keyDownloadUrl}" "${keyPath}"
}

function AddAptRepository () {
  repositoryUrl="${1}"
  repositoryFilePath="${2}"
  keyPath="${3}"
  if [[ -n "${keyPath}" ]]; then
    keyPathConfiguration=" signed-by=${keyPath}"
  fi
  architecture=$(dpkg --print-architecture)
  osCodeName=$(. /etc/os-release && echo "${VERSION_CODENAME}")
  repositoryFileContent="deb [arch=\"${architecture}\"${keyPathConfiguration}] ${repositoryUrl} \"${osCodeName}\" stable"
  SetFileContent "${repositoryFileContent}" "${repositoryFilePath}"
  ReloadAptRepositories
}
