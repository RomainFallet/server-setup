#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/docker/utilities.sh"

function StopDockerContainerIfExisting () {
  dockerContainerName="${1}"
  dockerContainerId=$(GetDockerContainerId "${dockerContainerName}")
  if [[ -n "${dockerContainerId}" ]]; then
    StopDockerContainerWithDockerCli "${dockerContainerName}"
  fi
}

function RemoveDockerContainerIfExisting () {
  dockerContainerName="${1}"
  dockerContainerId=$(GetDockerContainerId "${dockerContainerName}")
  if [[ -n "${dockerContainerId}" ]]; then
    StopDockerContainerWithDockerCli "${dockerContainerName}"
    RemoveDockerContainerWithDockerCli "${dockerContainerName}"
  fi
}
