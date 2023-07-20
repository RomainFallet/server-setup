#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SelectAppropriateGiteaArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "amd64"
  else
    echo "amd64"
  fi
}

function DownloadGiteaBinaryIfOutdated () {
  giteaLatestVersion="${1}"
  giteaCurrentVersion="${2}"
  giteaApplicationName="${3}"
  giteaBinaryPath="${4}"
  giteaBinaryDownloadPath="${5}"
  giteaArchitecture=$(SelectAppropriateGiteaArchitecture)
  echo "Gitea current version: ${giteaCurrentVersion}"
  echo "Gitea latest version: ${giteaLatestVersion}"
  if [[ "${giteaCurrentVersion}" != "${giteaLatestVersion}" ]]; then
    DownloadFile "https://dl.gitea.com/gitea/${giteaLatestVersion}/gitea-${giteaLatestVersion}-linux-${giteaArchitecture}" "${giteaBinaryDownloadPath}"
    MakeFileExecutable "${giteaBinaryDownloadPath}"
    CopyFile "${giteaBinaryDownloadPath}" "${giteaBinaryPath}"
    RemoveFile "${giteaBinaryDownloadPath}"
  fi
  SetFileOwnership "${giteaBinaryPath}" "${giteaApplicationName}"
}

function GetLatestGiteaVersion () {
  filePath=/tmp/gitea-version.json
  DownloadFile 'https://dl.gitea.com/gitea/version.json' "${filePath}"
  jq --raw-output .latest.version "${filePath}"
  RemoveFile "${filePath}"
}

function GetCurrentGiteaVersion () {
  if ! sudo test -f "${giteaBinaryPath}"; then
    echo 'uninstalled'
  else
    versionString=$(sudo "${giteaBinaryPath}" --version)
    echo "${versionString}" | awk '{print $3}'
  fi
}

function GetGiteaSecretKey () {
  keyName="${1}"
  keyNameInCamelCase=$(UpperCaseToCamelCase "${keyName}")
  giteaSecretKey=$(GetConfigurationFileValue /etc/server-setup/main.conf "${keyNameInCamelCase}")
  if [[ -z "${giteaSecretKey}" ]]; then
    giteaSecretKey=$(sudo su --command "${giteaBinaryPath} generate secret ${keyName}" - gitea)
    SetConfigurationFileValue /etc/server-setup/main.conf "${keyNameInCamelCase}" "${giteaSecretKey}"
  fi
  echo "${giteaSecretKey}"
}

function CreateOrUpdateGiteaAdminstratorAccount () {
  userName="${1}"
  userEmail="${2}"
  userPassword="${3}"
  giteaConfigurationFilePath="${4}"
  giteaDataPath="${5}"
  existingUsers=$(sudo su --command "${giteaBinaryPath} admin user list --config ${giteaConfigurationFilePath} --work-path ${giteaDataPath}" - gitea)
  existingUsernames=$(echo "${existingUsers}" | awk '{print $2}')
  if echo "${existingUsernames}" | grep "${userName}" > /dev/null; then
    sudo su --command "${giteaBinaryPath} admin user change-password --username '${userName}' --password '${userPassword}' --config ${giteaConfigurationFilePath} --work-path ${giteaDataPath}" - gitea
  else
    sudo su --command "${giteaBinaryPath} admin user create --username '${userName}' --password '${userPassword}' --email '${userEmail}' --admin --config ${giteaConfigurationFilePath} --work-path ${giteaDataPath}" - gitea
  fi
}
