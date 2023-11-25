#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/git/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/shell/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"

function InstallGit () {
  InstallPackageIfNotExisting 'git'
}

function InstallMailInABox () {
  MakeFileUnprotected /etc/resolv.conf
  CloneRepositoryIfNotExisting https://github.com/mail-in-a-box/mailinabox ~/mailinabox
  CheckoutRepository ~/mailinabox 'v65'
  ExecShellScriptWithRoot ~/mailinabox/ ./setup/start.sh
  resolvConfiguration="nameserver 45.90.28.193
nameserver 45.90.30.193"
  resolvConfigurationPath=/etc/resolv.conf
  SetFileContent "${resolvConfiguration}" "${resolvConfigurationPath}"
  MakeFileProtected /etc/resolv.conf
  StartService 'fix-mailinabox-permissions'
}

