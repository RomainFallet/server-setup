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
  CloneRepositoryIfNotExisting https://github.com/mail-in-a-box/mailinabox ~/mailinabox
  CheckoutRepository ~/mailinabox 'v68'
  ExecShellScriptWithRoot ~/mailinabox/ ./setup/start.sh
  StartService 'fix-mailinabox-permissions'
}

