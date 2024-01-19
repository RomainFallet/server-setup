#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SelectAppropriateMattermostArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "amd64"
  else
    echo "amd64"
  fi
}

function GetLatestMattermostVersion () {
  filePath=/tmp/mattermost-latest-release.html
  DownloadFile 'https://github.com/mattermost/mattermost/releases/latest' "${filePath}"
  releaseContent=$(cat "${filePath}")
  versionLine=$(echo "${releaseContent}" | grep "<title>Release v")
  rawVersion=$(echo "${versionLine}" | sed -E 's/<title>Release v([0-9]+)\.([0-9]+)\.([0-9]+).+/\1.\2.\3/g')
  version=$(Trim "${rawVersion}")
  RemoveFile "${filePath}"
  echo "${version}"
}

function GetCurrentMattermostVersion () {
  mattermostBinaryPath="${1}"
  if ! sudo test -f "${mattermostBinaryPath}"; then
    echo 'uninstalled'
  else
    versionString=$(sudo su --command "${mattermostBinaryPath} version" - mattermost)
    versionStringLine=$(echo "${versionString}" | grep '^Version')
    rawVersion=$(echo "${versionStringLine}" | awk '{print $2}')
    version=$(Trim "${rawVersion}")
    echo "${version}"
  fi
}

function DownloadMattermostIfOutdated () {
  mattermostDownloadPath="${1}"
  mattermostPath="${2}"
  mattermostArchitecture=$(SelectAppropriateMattermostArchitecture)
  mattermostCurrentVersion=$(GetCurrentMattermostVersion "${mattermostPath}"/bin/mmctl)
  mattermostLatestVersion=$(GetLatestMattermostVersion)
  echo "Mattermost current version: ${mattermostCurrentVersion}"
  echo "Mattermost latest version: ${mattermostLatestVersion}"
  if [[ "${mattermostCurrentVersion}" != "${mattermostLatestVersion}" ]]; then
    DownloadFile "https://releases.mattermost.com/${mattermostLatestVersion}/mattermost-${mattermostLatestVersion}-linux-${mattermostArchitecture}.tar.gz" "${mattermostDownloadPath}"
    ExctractTarFile "${mattermostDownloadPath}" /tmp
    RemoveDirectory "${mattermostPath}"
    CopyDirectory /tmp/mattermost "${mattermostPath}"
    RemoveFile "${mattermostDownloadPath}"
    RemoveDirectory /tmp/mattermost
  fi
}

function CreateOrUpdateMattermostAdministratorAccount () {
  userName="${1}"
  userEmail="${2}"
  userPassword="${3}"
  mattermostApplicationName="${4}"
  existingUsers=$(sudo su --command "/var/opt/mattermost/bin/mmctl --local user list" - "${mattermostApplicationName}")
  if echo "${existingUsers}" | grep "${userEmail}" > /dev/null; then
    sudo su --command "/var/opt/mattermost/bin/mmctl --local user change-password '${userName}' --password '${userPassword}'" - "${mattermostApplicationName}"
  else
    sudo su --command "/var/opt/mattermost/bin/mmctl --local user create --system-admin --email '${userEmail}' --username '${userName}' --password '${userPassword}'" - "${mattermostApplicationName}"
  fi
}

function CreateOrUpdateMattermostDefaultTeam () {
  teamIdentifier="${1}"
  teamName="${2}"
  administratorUserName="${3}"
  mattermostApplicationName="${4}"
  existingTeams=$(sudo su --command "/var/opt/mattermost/bin/mmctl --local team list" - "${mattermostApplicationName}")
  if ! echo "${existingTeams}" | grep "${teamIdentifier}" > /dev/null; then
    sudo su --command "/var/opt/mattermost/bin/mmctl --local team create --name '${teamIdentifier}' --display-name '${teamName}' --private" - "${mattermostApplicationName}"
  fi
  sudo su --command "/var/opt/mattermost/bin/mmctl --local team users add '${teamIdentifier}' '${administratorUserName}'" - "${mattermostApplicationName}"
}

function SetMattermostConfiguration () {
  configurationKey="${1}"
  configurationValue="${2}"
  mattermostApplicationName="${3}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local config set '${configurationKey}' ${configurationValue}" - "${mattermostApplicationName}"
}

function ConfigureMattermost() {
  mattermostApplicationName="${1}"
  mattermortFilesDirectory="${2}"
  mattermostPluginsDirectory="${3}"
  mattermostClientPluginsDirectory="${4}"
  AskIfNotSet mattermostDomainName "Enter your Mattermost domain name"
  AskIfNotSet mattermostInternalPort "Enter your Mattermost internal port"
  AskIfNotSet mattermostSmtpHostName "Enter your Mattermost SMTP hostname"
  AskIfNotSet mattermostSmtpUserName "Enter your Mattermost SMTP username" "${mattermostApplicationName}@${mattermostSmtpHostName:?}"
  AskIfNotSet mattermostSmtpPassword "Enter your Mattermost SMTP password"
  AskIfNotSet mattermostSmtpPort "Enter your Mattermost SMTP port" '465'
  SetMattermostConfiguration 'ServiceSettings.ListenAddress' ":${mattermostInternalPort:?}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'ServiceSettings.SiteURL' "https://${mattermostDomainName:?}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'ServiceSettings.EnableLocalMode' true "${mattermostApplicationName}"
  SetMattermostConfiguration 'ServiceSettings.TrustedProxyIPHeader' "'Upgrade' 'Connection' 'Host' 'X-Real-IP' 'X-Forwarded-For' 'X-Forwarded-Proto' 'X-Frame-Options'" "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.EnableSignUpWithEmail' true "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.EnableSignInWithEmail' true "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.EnableSignInWithUsername' false "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.SendEmailNotifications' true "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.RequireEmailVerification' false "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.EnableSMTPAuth' true "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.SMTPUsername' "${mattermostSmtpUserName:?}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.SMTPPassword' "${mattermostSmtpPassword:?}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.SMTPServer' "${mattermostSmtpHostName:?}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.SMTPPort' "${mattermostSmtpPort:?}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.ConnectionSecurity' 'TLS' "${mattermostApplicationName}"
  SetMattermostConfiguration 'LogSettings.EnableSentry' false "${mattermostApplicationName}"
  SetMattermostConfiguration 'PasswordSettings.MinimumLength' 12 "${mattermostApplicationName}"
  SetMattermostConfiguration 'LocalizationSettings.DefaultServerLocale' 'fr' "${mattermostApplicationName}"
  SetMattermostConfiguration 'LocalizationSettings.DefaultClientLocale' 'fr' "${mattermostApplicationName}"
  SetMattermostConfiguration 'PluginSettings.Directory' "${mattermostPluginsDirectory}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'PluginSettings.ClientDirectory' "${mattermostClientPluginsDirectory}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'FileSettings.DriverName' local "${mattermostApplicationName}"
  SetMattermostConfiguration 'FileSettings.Directory' "${mattermortFilesDirectory}" "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.SendPushNotifications' true "${mattermostApplicationName}"
  SetMattermostConfiguration 'EmailSettings.PushNotificationServer' 'https://push-test.mattermost.com' "${mattermostApplicationName}"
}

function WaitForMattermostSocketToBeCreated() {
  mattermostSocketPath="${1}"
  elapsedTime=0
  # shellcheck disable=SC2065
  while ! test -e "${mattermostSocketPath}" > /dev/null
  do
    timeToWaitInSeconds=1
    sleep "${timeToWaitInSeconds}"s
    elapsedTime=$(("${elapsedTime}" + 1))
    echo "Waiting for Mattermost socket to be created... [elapsed time: ${elapsedTime}s]"
    if [[ "${elapsedTime}" == '100' ]]; then
      break
    fi
  done
}

function ManageMattermostPlugins () {
  mattermostApplicationName="${1}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'com.mattermost.calls'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin delete 'com.mattermost.calls'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'com.mattermost.nps'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin delete 'com.mattermost.nps'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'playbooks'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin delete 'playbooks'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'com.mattermost.apps'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'focalboard'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'jitsi'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin marketplace install 'com.mattermost.apps'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin marketplace install 'focalboard'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin marketplace install 'jitsi'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin enable 'com.mattermost.apps'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin enable 'focalboard'" - "${mattermostApplicationName}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin enable 'jitsi'" - "${mattermostApplicationName}"
}

function SetMattermostConfigurationFileContent () {
  configurationFilePath="${1}"
  postgresqlUsername="${2}"
  postgresqlPassword="${3}"
  postgresqlDatabaseName="${4}"
  configuration="{
    \"ServiceSettings\": {
      \"EnableLocalMode\": true
    },
    \"SqlSettings\": {
      \"DataSource\": \"postgres://${postgresqlUsername}:${postgresqlPassword}@localhost:5432/${postgresqlDatabaseName}?sslmode=disable&connect_timeout=10\"
    }
  }"
  SetFileContent "${configuration}" "${configurationFilePath}"
}
