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

function CreateOrUpdateMattermostAdminstratorAccount () {
  userName="${1}"
  userEmail="${2}"
  userPassword="${3}"
  existingUsers=$(sudo su --command "/var/opt/mattermost/bin/mmctl --local user list" - mattermost)
  if echo "${existingUsers}" | grep "${userEmail}" > /dev/null; then
    sudo su --command "/var/opt/mattermost/bin/mmctl --local user change-password '${userName}' --password '${userPassword}'" - mattermost
  else
    sudo su --command "/var/opt/mattermost/bin/mmctl --local user create --system-admin --email '${userEmail}' --username '${userName}' --password '${userPassword}'" - mattermost
  fi
}

function CreateOrUpdateMattermostDefaultTeam () {
  teamIdentifier="${1}"
  teamName="${2}"
  administratorUserName="${3}"
  existingTeams=$(sudo su --command "/var/opt/mattermost/bin/mmctl --local team list" - mattermost)
  if ! echo "${existingTeams}" | grep "${teamIdentifier}" > /dev/null; then
    sudo su --command "/var/opt/mattermost/bin/mmctl --local team create --name '${teamIdentifier}' --display-name '${teamName}' --private" - mattermost
  fi
  sudo su --command "/var/opt/mattermost/bin/mmctl --local team users add '${teamIdentifier}' '${administratorUserName}'" - mattermost
}

function SetMattermostConfiguration () {
  configurationKey="${1}"
  configurationValue="${2}"
  sudo su --command "/var/opt/mattermost/bin/mmctl --local config set '${configurationKey}' ${configurationValue}" - mattermost
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
  SetMattermostConfiguration 'ServiceSettings.ListenAddress' ":${mattermostInternalPort:?}"
  SetMattermostConfiguration 'ServiceSettings.SiteURL' "https://${mattermostDomainName:?}"
  SetMattermostConfiguration 'ServiceSettings.EnableLocalMode' true
  SetMattermostConfiguration 'ServiceSettings.TrustedProxyIPHeader' 'Upgrade' 'Connection' 'Host' 'X-Real-IP' 'X-Forwarded-For' 'X-Forwarded-Proto' 'X-Frame-Options'
  SetMattermostConfiguration 'EmailSettings.EnableSignUpWithEmail' true
  SetMattermostConfiguration 'EmailSettings.EnableSignInWithEmail' true
  SetMattermostConfiguration 'EmailSettings.EnableSignInWithUsername' false
  SetMattermostConfiguration 'EmailSettings.SendEmailNotifications' true
  SetMattermostConfiguration 'EmailSettings.RequireEmailVerification' false
  SetMattermostConfiguration 'EmailSettings.EnableSMTPAuth' true
  SetMattermostConfiguration 'EmailSettings.SMTPUsername' "${mattermostSmtpUserName:?}"
  SetMattermostConfiguration 'EmailSettings.SMTPPassword' "${mattermostSmtpPassword:?}"
  SetMattermostConfiguration 'EmailSettings.SMTPServer' "${mattermostSmtpHostName:?}"
  SetMattermostConfiguration 'EmailSettings.SMTPPort' "${mattermostSmtpPort:?}"
  SetMattermostConfiguration 'EmailSettings.ConnectionSecurity' 'TLS'
  SetMattermostConfiguration 'LogSettings.EnableSentry' false
  SetMattermostConfiguration 'PasswordSettings.MinimumLength' 12
  SetMattermostConfiguration 'LocalizationSettings.DefaultServerLocale' 'fr'
  SetMattermostConfiguration 'LocalizationSettings.DefaultClientLocale' 'fr'
  SetMattermostConfiguration 'PluginSettings.Directory' "${mattermostPluginsDirectory}"
  SetMattermostConfiguration 'PluginSettings.ClientDirectory' "${mattermostClientPluginsDirectory}"
  SetMattermostConfiguration 'FileSettings.DriverName' local
  SetMattermostConfiguration 'FileSettings.Directory' "${mattermortFilesDirectory}"
  SetMattermostConfiguration 'EmailSettings.SendPushNotifications' true
  SetMattermostConfiguration 'EmailSettings.PushNotificationServer' 'https://push-test.mattermost.com'
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
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'com.mattermost.calls'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin delete 'com.mattermost.calls'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'com.mattermost.nps'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin delete 'com.mattermost.nps'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'playbooks'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin delete 'playbooks'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'com.mattermost.apps'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'focalboard'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin disable 'jitsi'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin marketplace install 'com.mattermost.apps'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin marketplace install 'focalboard'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin marketplace install 'jitsi'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin enable 'com.mattermost.apps'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin enable 'focalboard'" - mattermost
  sudo su --command "/var/opt/mattermost/bin/mmctl --local plugin enable 'jitsi'" - mattermost
}
