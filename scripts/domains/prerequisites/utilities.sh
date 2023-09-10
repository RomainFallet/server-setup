#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function InstallDocker () {
  AddGpgKey 'https://download.docker.com/linux/ubuntu/gpg' /etc/apt/keyrings/docker.gpg
  AddAptRepository 'https://download.docker.com/linux/ubuntu' /etc/apt/sources.list.d/docker.list /etc/apt/keyrings/docker.gpg
  InstallPackageIfNotExisting 'docker-ce'
  InstallPackageIfNotExisting 'docker-ce-cli'
  InstallPackageIfNotExisting 'containerd.io'
}
