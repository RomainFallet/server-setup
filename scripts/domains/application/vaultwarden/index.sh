#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/shell/index.sh"

function SetupVaultwarden () {
  extractScriptPath=/tmp/docker-image-extract
  DownloadFile "https://raw.githubusercontent.com/jjlin/docker-image-extract/main/docker-image-extract" "${extractScriptPath}"
  MakeFileExecutable "${extractScriptPath}"
  ExecShellScript /tmp ./docker-image-extract vaultwarden/server:latest-alpine
}
