#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SelectAppropriateListmonkArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "amd64"
  else
    echo "amd64"
  fi
}

function GetLatestListmonkVersion () {
  filePath=/tmp/listmonk-latest-release.html
  DownloadFile 'https://github.com/knadh/listmonk/releases/latest' "${filePath}"
  releaseContent=$(cat "${filePath}")
  versionLine=$(echo "${releaseContent}" | grep "<title>Release v")
  rawVersion=$(echo "${versionLine}" | sed -E 's/<title>Release v([0-9]+)\.([0-9]+)\.([0-9]+).+/\1.\2.\3/g')
  version=$(Trim "${rawVersion}")
  RemoveFile "${filePath}"
  echo "${version}"
}

function GetCurrentListmonkVersion () {
  listmonkBinaryPath="${1}"
  if ! sudo test -f "${listmonkBinaryPath}"; then
    echo 'uninstalled'
  else
    versionString=$(sudo su --command "${listmonkBinaryPath} --version" - listmonk)
    versionColumn=$(echo "${versionString}" | awk '{print $1}')
    rawVersion=$(echo "${versionColumn}" | sed -E 's/^v//g')
    version=$(Trim "${rawVersion}")
    echo "${version}"
  fi
}

function DownloadListmonkIfOutdated () {
  listmonkDownloadPath="${1}"
  listmonkBinaryPath="${2}"
  listmonkArchitecture=$(SelectAppropriateListmonkArchitecture)
  listmonkCurrentVersion=$(GetCurrentListmonkVersion "${listmonkBinaryPath}")
  listmonkLatestVersion=$(GetLatestListmonkVersion)
  echo "Listmonk current version: ${listmonkCurrentVersion}"
  echo "Listmonk latest version: ${listmonkLatestVersion}"
  if [[ "${listmonkCurrentVersion}" != "${listmonkLatestVersion}" ]]; then
    DownloadFile "https://github.com/knadh/listmonk/releases/download/v${listmonkLatestVersion}/listmonk_${listmonkLatestVersion}_linux_${listmonkArchitecture}.tar.gz" "${listmonkDownloadPath}"
    ExctractTarFile "${listmonkDownloadPath}" /tmp
    RemoveFile "${listmonkBinaryPath}"
    CopyFile /tmp/listmonk "${listmonkBinaryPath}"
    MakeFileExecutable "${listmonkBinaryPath}"
    RemoveFile "${listmonkDownloadPath}"
    RemoveFile /tmp/listmonk
    RemoveFile /tmp/README.md
    RemoveFile /tmp/LICENSE
  fi
}

function ConfigureListmonk () {
  configurationFilePath="${1}"
  listmonkInternalPort="${2}"
  postgresqlUsername="${3}"
  postgresqlPassword="${4}"
  postgresqlDatabaseName="${5}"
  administratorUserName="${6}"
  administratorPassword="${7}"
  configuration="[app]
address = \"localhost:${listmonkInternalPort}\"

admin_username = \"${administratorUserName}\"
admin_password = \"${administratorPassword}\"

[db]
host = \"localhost\"
port = 5432
user = \"${postgresqlUsername}\"
password = \"${postgresqlPassword}\"

database = \"${postgresqlDatabaseName}\"

ssl_mode = \"disable\"
max_open = 25
max_idle = 25
max_lifetime = \"300s\"

# Optional space separated Postgres DSN params. eg: \"application_name=listmonk gssencmode=disable\"
params = \"\""
  SetFileContent "${configuration}" "${configurationFilePath}"
}

function ConfigureListmonkDatabase () {
  listmonkBinaryPath="${1}"
  listmonkConfigurationFilePath="${2}"
  listmonkApplicationName="${3}"
  sudo su --command "${listmonkBinaryPath} --config ${listmonkConfigurationFilePath} --install --idempotent --yes" - "${listmonkApplicationName}"
}
