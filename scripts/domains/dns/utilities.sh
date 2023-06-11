#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function CreateNextDnsConfiguration () {
  fileContent="nameserver 45.90.28.193
nameserver 45.90.30.193"
  filePath=/etc/resolv.conf
  SetFileContent "${fileContent}" "${filePath}"
}
