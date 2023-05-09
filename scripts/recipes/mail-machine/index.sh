#!/bin/bash

# shellcheck source=../../domains/security/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source=../../domains/system/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source=../../domains/backup/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/backup/index.sh"

SetUpSsh
SetUpBasicSystemConfiguration
# shellcheck disable=SC2119
SetUpMailMachineBackups
