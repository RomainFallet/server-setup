#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SelectAppropriateVaultwardenArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "linux/arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "linux/amd64"
  else
    echo "linux/amd64"
  fi
}

function DownloadLatestVaultwardenRelease () {
  vaultwardenOutputPath="${1}"
  extractScriptPath=/tmp/docker-image-extract
  DownloadFile "https://raw.githubusercontent.com/jjlin/docker-image-extract/main/docker-image-extract" "${extractScriptPath}"
  MakeFileExecutable "${extractScriptPath}"
  architecture=$(SelectAppropriateVaultwardenArchitecture)
  sudo /tmp/docker-image-extract -p "${architecture}" -o "${vaultwardenOutputPath}" vaultwarden/server:latest-alpine
  RemoveFile /tmp/docker-image-extract
}

function GetLatestVaultwardenVersion () {
  filePath=/tmp/vaultwarden-latest-release.html
  DownloadFile 'https://github.com/dani-garcia/vaultwarden/releases/latest' "${filePath}"
  releaseContent=$(cat "${filePath}")
  versionLine=$(echo "${releaseContent}" | grep "<title>Release ")
  rawVersion=$(echo "${versionLine}" | sed -E 's/<title>Release v*([0-9]+)\.([0-9]+)\.([0-9]+).+/\1.\2.\3/g')
  version=$(Trim "${rawVersion}")
  RemoveFile "${filePath}"
  echo "${version}"
}

function GetCurrentVaultwardenVersion () {
  vaultwardenBinaryPath="${1}"
  vaultwardenUsername="${2}"
  if ! sudo test -f "${vaultwardenBinaryPath}"; then
    echo 'uninstalled'
  else
    versionString=$(sudo su --command "${vaultwardenBinaryPath} --version" - "${vaultwardenUsername}")
    rawVersion=$(echo "${versionString}" | awk '{print $2}')
    version=$(Trim "${rawVersion}")
    echo "${version}"
  fi
}

function DownloadVaultwardenIfOutdated () {
  vaultwardenUserName="${1}"
  vaultwardenBinaryPath="${2}"
  vaultwardenOutputPath="${3}"
  vaultwardenPath="${4}"
  vaultwardenCurrentVersion=$(GetCurrentVaultwardenVersion "${vaultwardenBinaryPath}" "${vaultwardenUserName}")
  vaultwardenLatestVersion=$(GetLatestVaultwardenVersion)
  echo "Vaultwarden current version: ${vaultwardenCurrentVersion}"
  echo "Vaultwarden latest version: ${vaultwardenLatestVersion}"
  if [[ "${vaultwardenCurrentVersion}" != "${vaultwardenLatestVersion}" ]]; then
    RemoveDirectory "${vaultwardenOutputPath}"
    DownloadLatestVaultwardenRelease "${vaultwardenOutputPath}"
    RemoveFile "${vaultwardenBinaryPath}"
    CopyFile "${vaultwardenOutputPath}/vaultwarden" "${vaultwardenBinaryPath}"
    RemoveDirectory "${vaultwardenPath}/web-vault"
    CopyDirectory "${vaultwardenOutputPath}/web-vault" "${vaultwardenPath}"
    RemoveDirectory "${vaultwardenOutputPath}"
  fi
}

function ConfigureVaultwarden () {
  vaultwardenApplicationName="${1}"
  vaultwardenDataPath="${2}"
  vaultwardenLogPath="${3}"
  vaultwardenDatabaseName="${4}"
  vaultwardenDatabasePassword="${5}"
  vaultwardenAdminPassword="${6}"
  vaultwardenDomainName="${7}"
  vaultwardenSmtpHostName="${8}"
  vaultwardenSmtpUserName="${9}"
  vaultwardenSmtpPassword="${10}"
  vaultwardenSmtpPort="${11}"
  vaultwardenEnvironmentPath="${12}"
  vaultwardenInternalPort="${13}"
  vaultwardenWebvaultPath="${14}"
  InstallPackageIfNotExisting 'argon2'
  vaultwardenAdminToken=$(echo -n "${vaultwardenAdminPassword}" | argon2 "$(openssl rand -base64 32 || true)" -e -id -k 19456 -t 2 -p 1)
  vaultwardenConfiguration="ROCKET_PORT=${vaultwardenInternalPort}
DATA_FOLDER=${vaultwardenDataPath}
DATABASE_URL=postgresql://${vaultwardenApplicationName}:${vaultwardenDatabasePassword}@localhost:5432/${vaultwardenDatabaseName}
LOG_FILE=${vaultwardenLogPath}
SIGNUPS_ALLOWED=false
SIGNUPS_VERIFY=true
ADMIN_TOKEN='${vaultwardenAdminToken}'
DOMAIN=https://${vaultwardenDomainName}
SMTP_HOST=${vaultwardenSmtpHostName}
SMTP_FROM=${vaultwardenSmtpUserName}
SMTP_FROM_NAME=Vaultwarden
SMTP_AUTH_MECHANISM=Plain
SMTP_SECURITY=force_tls
SMTP_PORT=${vaultwardenSmtpPort}
SMTP_USERNAME=${vaultwardenSmtpUserName}
SMTP_PASSWORD=${vaultwardenSmtpPassword}
HELO_NAME=${vaultwardenSmtpHostName}
WEB_VAULT_FOLDER=${vaultwardenWebvaultPath}"
  SetFileContent "${vaultwardenConfiguration}" "${vaultwardenEnvironmentPath}"
}
