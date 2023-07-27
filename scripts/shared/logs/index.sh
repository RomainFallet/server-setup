#!/bin/bash


# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/logs/utilities.sh"

function ConfigureLogRotation () {
  ConfigureLogRotate
  ConfigureLogRotateHourlyExecution
}

function CleanOldLogs () {
  CleanOldFileLogs
  CleanOldSystemctlLogs
}
