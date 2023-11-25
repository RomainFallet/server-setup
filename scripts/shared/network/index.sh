#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/network/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"

function EnableNetworkConfiguration () {
  EnableNetplanConfiguration
  RestartService 'systemd-networkd'
  RestartService 'systemd-resolved'
}
