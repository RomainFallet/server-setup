#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SelectAppropriateForgejoArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "amd64"
  else
    echo "amd64"
  fi
}

function DownloadForgejoBinaryIfOutdated () {
  forgejoLatestVersion="${1}"
  forgejoCurrentVersion="${2}"
  forgejoApplicationName="${3}"
  forgejoBinaryPath="${4}"
  forgejoBinaryDownloadPath="${5}"
  forgejoArchitecture=$(SelectAppropriateForgejoArchitecture)
  echo "Forgejo current version: ${forgejoCurrentVersion}"
  echo "Forgejo latest version: ${forgejoLatestVersion}"
  if [[ "${forgejoCurrentVersion}" != "${forgejoLatestVersion}" ]]; then
    DownloadFile "https://codeberg.org/forgejo/forgejo/releases/download/v${forgejoLatestVersion}/forgejo-${forgejoLatestVersion}-linux-${forgejoArchitecture}" "${forgejoBinaryDownloadPath}"
    MakeFileExecutable "${forgejoBinaryDownloadPath}"
    CopyFile "${forgejoBinaryDownloadPath}" "${forgejoBinaryPath}"
    RemoveFile "${forgejoBinaryDownloadPath}"
  fi
  SetFileOwnership "${forgejoBinaryPath}" "${forgejoApplicationName}"
}

function GetLatestForgejoVersion () {
  filePath=/tmp/forgejo-latest-release.html
  DownloadFile 'https://codeberg.org/forgejo/forgejo/releases/latest' "${filePath}"
  releaseContent=$(cat "${filePath}")
  versionLine=$(echo "${releaseContent}" | grep "<title>v")
  rawVersion=$(echo "${versionLine}" | sed -E 's/<title>v([0-9]+)\.([0-9]+)\.([0-9]+).+/\1.\2.\3/g')
  version=$(Trim "${rawVersion}")
  RemoveFile "${filePath}"
  echo "${version}"
}

function GetCurrentForgejoVersion () {
  if ! sudo test -f "${forgejoBinaryPath}"; then
    echo 'uninstalled'
  else
    versionString=$(sudo "${forgejoBinaryPath}" --version)
    versionColumn=$(echo "${versionString}" | awk '{print $3}')
    version=$(echo "${versionColumn}" | sed -E 's/(.+)\+(.+)/\1/')
    echo "${version}"
  fi
}

function GetLatestForgejoRunnerVersion () {
  filePath=/tmp/forgejo-runner-latest-release.json
  DownloadFile 'https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest' "${filePath}"
  releaseContent=$(cat "${filePath}")
  versionLine=$(echo "${releaseContent}" | jq .name -r)
  version=$(echo "${versionLine}" | cut -c 2-)
  RemoveFile "${filePath}"
  echo "${version}"
}

function GetCurrentForgejoRunnerVersion () {
  forgejoRunnerBinaryPath="${1}"
  if ! sudo test -f "${forgejoRunnerBinaryPath}"; then
    echo 'uninstalled'
  else
    versionString=$(sudo "${forgejoRunnerBinaryPath}" -v)
    versionColumn=$(echo "${versionString}" | awk '{print $3}')
    version=$(echo "${versionColumn}" | cut -c 2-)
    echo "${version}"
  fi
}

function DownloadForgejoRunnerBinaryIfOutdated () {
  forgejoRunnerLatestVersion="${1}"
  forgejoRunnerCurrentVersion="${2}"
  forgejoRunnerBinaryPath="${3}"
  forgejoRunnerBinaryDownloadPath="${4}"
  forgejoArchitecture=$(SelectAppropriateForgejoArchitecture)
  echo "Forgejo runner current version: ${forgejoRunnerCurrentVersion}"
  echo "Forgejo runner latest version: ${forgejoRunnerLatestVersion}"

  if [[ "${forgejoRunnerCurrentVersion}" != "${forgejoRunnerLatestVersion}" ]]; then
    DownloadFile "https://data.forgejo.org/forgejo/runner/releases/download/v${forgejoRunnerLatestVersion}/forgejo-runner-${forgejoRunnerLatestVersion}-linux-${forgejoArchitecture}" "${forgejoRunnerBinaryDownloadPath}"
    MakeFileExecutable "${forgejoRunnerBinaryDownloadPath}"
    CopyFile "${forgejoRunnerBinaryDownloadPath}" "${forgejoRunnerBinaryPath}"
    RemoveFile "${forgejoRunnerBinaryDownloadPath}"
  fi
}

function GetForgejoSecretKey () {
  keyName="${1}"
  keyNameInCamelCase=$(UpperCaseToCamelCase "${keyName}")
  forgejoSecretKey=$(GetConfigurationFileValue /etc/server-setup/main.conf "${keyNameInCamelCase}")
  if [[ -z "${forgejoSecretKey}" ]]; then
    forgejoSecretKey=$(sudo su --command "${forgejoBinaryPath} generate secret ${keyName}" - forgejo)
    SetConfigurationFileValue /etc/server-setup/main.conf "${keyNameInCamelCase}" "${forgejoSecretKey}"
  fi
  echo "${forgejoSecretKey}"
}

function GetForgejoRunnerSecret () {
  runnerName="${1}"
  forgejoConfigurationFilePath="${2}"
  forgejoRunnerSecretName="${runnerName}Secret"
  forgejoRunnerSecretKey=$(GetConfigurationFileValue /etc/server-setup/main.conf "${forgejoRunnerSecretName}")
  if [[ -z "${forgejoRunnerSecretKey}" ]]; then
    forgejoRunnerSecretKey=$(sudo su --command "${forgejoBinaryPath} --config ${forgejoConfigurationFilePath} forgejo-cli actions generate-secret" - forgejo)
    SetConfigurationFileValue /etc/server-setup/main.conf "${forgejoRunnerSecretName}" "${forgejoRunnerSecretKey}"
  fi
  echo "${forgejoRunnerSecretKey}"
}

function RegisterForgejoRunner () {
  runnerName="${1}"
  runnerSecret="${2}"
  forgejoInstanceUrl="${3}"
  forgejoConfigurationFilePath="${4}"
  sudo su --command "${forgejoBinaryPath} --config ${forgejoConfigurationFilePath} forgejo-cli actions register --name ${runnerName} --secret ${runnerSecret} --labels self-hosted" - forgejo
  sudo su --login --command "${forgejoRunnerBinaryPath} create-runner-file --instance ${forgejoInstanceUrl} --secret ${runnerSecret} --name ${runnerName}" - "${runnerName}"
}

function CreateOrUpdateForgejoAdminstratorAccount () {
  userName="${1}"
  userEmail="${2}"
  userPassword="${3}"
  forgejoConfigurationFilePath="${4}"
  forgejoDataPath="${5}"
  existingUsers=$(sudo su --command "${forgejoBinaryPath} admin user list --config ${forgejoConfigurationFilePath} --work-path ${forgejoDataPath}" - forgejo)
  existingUsernames=$(echo "${existingUsers}" | awk '{print $2}')
  if echo "${existingUsernames}" | grep "${userName}" > /dev/null; then
    sudo su --command "${forgejoBinaryPath} admin user change-password --username '${userName}' --password '${userPassword}' --config ${forgejoConfigurationFilePath} --work-path ${forgejoDataPath}" - forgejo
  else
    sudo su --command "${forgejoBinaryPath} admin user create --username '${userName}' --password '${userPassword}' --email '${userEmail}' --admin --config ${forgejoConfigurationFilePath} --work-path ${forgejoDataPath}" - forgejo
  fi
}
