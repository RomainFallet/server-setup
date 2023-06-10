#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/utilities.sh"

function SetUpBasicSystemConfiguration () {
  # shellcheck disable=SC2119
  SetTimeZone
  # shellcheck disable=SC2119
  SetHostName
  SetUpUnattentedUpgrade
}

function SetUpAutomaticUpdates () {
  SetUpUnattentedUpgrade
}
