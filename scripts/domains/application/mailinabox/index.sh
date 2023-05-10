#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mailinabox/utilities.sh"

function SetUpMailInABox () {
  InstallGit
  InstallMailInABox
}
