#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/network/utilities.sh"

function EnableNetworkConfiguration () {
  EnableNetplanConfiguration
}
