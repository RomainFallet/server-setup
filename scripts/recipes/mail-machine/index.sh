#!/bin/bash

# shellcheck source=../../domains/ssh/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/ssh/index.sh"
# shellcheck source=../../domains/system/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/system/index.sh"

SetUpSsh
SetUpBasicSystemConfiguration
