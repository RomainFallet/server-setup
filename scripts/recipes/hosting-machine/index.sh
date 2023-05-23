#!/bin/bash

# shellcheck source=../../domains/security/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source=../../domains/system/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source=../../domains/prerequisites/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/prerequisites/index.sh"

SetUpSsh
SetUpFail2Ban
SetUpMachineFireWall
SetUpBasicSystemConfiguration
SetUpHostingMachinePrerequisites
