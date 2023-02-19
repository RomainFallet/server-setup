#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/fail2ban/utilities.sh"

function SetUpFail2Ban () {
  InstallFail2BanIfNotExisting
  CreateDefaultConfiguration
  RestartFail2Ban
}

export -f SetUpFail2Ban
