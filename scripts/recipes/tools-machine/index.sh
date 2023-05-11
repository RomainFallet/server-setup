#!/bin/bash

# shellcheck source=../../domains/security/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source=../../domains/system/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"

set -e

SetUpSsh
SetUpBasicSystemConfiguration
SetUpFail2Ban
