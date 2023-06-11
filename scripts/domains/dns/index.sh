#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/dns/utilities.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SetUpNextDns () {
  MakeFileUnprotected /etc/resolv.conf
  CreateNextDnsConfiguration
  MakeFileProtected /etc/resolv.conf
}
