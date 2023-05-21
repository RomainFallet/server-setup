#!/bin/bash

# shellcheck source=../../../shared/packages/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source=../../../shared/git/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/git/index.sh"
# shellcheck source=../../../shared/shell/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/shell/index.sh"

function InstallGit () {
  InstallPackageIfNotExisting 'git'
}

function InstallMailInABox () {
  CloneRepositoryIfNotExisting https://github.com/mail-in-a-box/mailinabox ~/mailinabox
  CheckoutRepository ~/mailinabox 'v62'
  ExecShellScriptWithRoot ~/mailinabox/ ./setup/start.sh
}
