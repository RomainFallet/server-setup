#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/utilities.sh"

function CreateService () {
  name="${1}"
  executablePath="${2}"
  userName="${3}"
  workingDirectory="${4}"
  environmentPath="${5}"
  afterServiceName="${6}"

  workingDirectoryConfiguration=''
  environmentConfiguration=''
  if [[ -n "${workingDirectory}" ]]; then
    workingDirectoryConfiguration="
WorkingDirectory=${workingDirectory}"
  fi
  if [[ -n "${environmentPath}" ]]; then
    environmentConfiguration="
EnvironmentFile=${environmentPath}"
  fi
  if [[ -n "${afterServiceName}" ]]; then
    afterServiceNameConfiguration="
After=${afterServiceName}"
  fi
  fileContent="[Unit]
Description=${name}
After=syslog.target
After=network.target${afterServiceNameConfiguration}

[Service]
Type=simple
ExecStart=${executablePath}
Restart=on-failure
RestartSec=2s
User=${userName}
Group=${userName}${workingDirectoryConfiguration}${environmentConfiguration}

[Install]
WantedBy=multi-user.target"
  filePath=/etc/systemd/system/"${name}".service
  SetFileContent "${fileContent}" "${filePath}"
  ReloadSystemdServiceFiles
}

function CreateStartupServiceWatcher () {
  serviceName="${1}"
  serviceWatcherName="${serviceName}-watcher"
  servicePath="${2}"
  watcherConfiguration="[Unit]
Description=${serviceName} restarter
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl restart ${serviceName}.service

[Install]
WantedBy=multi-user.target"
  watcherConfigurationPath=/etc/systemd/system/"${serviceWatcherName}".service
  SetFileContent "${watcherConfiguration}" "${watcherConfigurationPath}"
  directoryConfiguration="[Path]
Unit=${serviceWatcherName}.service
PathChanged=${servicePath}
TriggerLimitBurst=1
TriggerLimitIntervalSec=5

[Install]
WantedBy=multi-user.target"
  directoryConfigurationPath=/etc/systemd/system/"${serviceWatcherName}".path
  SetFileContent "${directoryConfiguration}" "${directoryConfigurationPath}"
  EnableSystemdService "${serviceWatcherName}"
  EnableSystemdPath "${serviceWatcherName}"
}

function CreateStartupService () {
  name="${1}"
  executablePath="${2}"
  userName="${3}"
  workingDirectory="${4}"
  environmentPath="${5}"
  afterServiceName="${6}"

  CreateService "${name}" "${executablePath}" "${userName}" "${workingDirectory}" "${environmentPath}" "${afterServiceName}"
  EnableSystemdService "${name}"
}

function DisableService () {
  serviceName="${1}"
  DisableSystemdService "${serviceName}"
}

function RestartService () {
  serviceName="${1}"
  RestartSystemdService "${serviceName}"
}

function RestartServicePath () {
  serviceName="${1}"
  RestartSystemdPath "${serviceName}"
}

function StartService () {
  serviceName="${1}"
  StartSystemdService "${serviceName}"
}

function StopService () {
  serviceName="${1}"
  StopSystemdService "${serviceName}"
}

function FollowServiceLogs () {
  serviceName="${1}"
  FollowSystemdServiceLogs "${serviceName}"
}
