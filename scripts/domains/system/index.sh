#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/logs/index.sh"

function SetUpBasicSystemConfiguration () {
  # shellcheck disable=SC2119
  SetTimeZone
  # shellcheck disable=SC2119
  SetHostName
  SetUpUnattentedUpgrades
  SetUpIpv6
  ConfigureLogRotation
}

function SetUpAutomaticUpdates () {
  SetUpUnattentedUpgrades
}
