#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/security/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/prerequisites/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/drone-ci-runner/index.sh"

SetUpCiRunnerMachinePrerequisites
SetUpSsh
SetUpFail2Ban
SetUpMachineFireWall
SetUpBasicSystemConfiguration
SetupDroneCiRunner
