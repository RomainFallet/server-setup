#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
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

function InstallDocker () {
  dockerRepositoryKeyUrl='https://download.docker.com/linux/ubuntu/gpg'
  dockerRepositoryKeyPath=/etc/apt/keyrings/docker.gpg
  dockerRepositoryUrl='https://download.docker.com/linux/ubuntu'
  dockerRepositoryFilePath=/etc/apt/sources.list.d/docker.list
  AddGpgKey "${dockerRepositoryKeyUrl}" "${dockerRepositoryKeyPath}"
  AddAptRepository "${dockerRepositoryUrl}" "${dockerRepositoryFilePath}" "${dockerRepositoryKeyPath}"
  InstallPackageIfNotExisting 'docker-ce'
  InstallPackageIfNotExisting 'docker-ce-cli'
  InstallPackageIfNotExisting 'containerd.io'
}
