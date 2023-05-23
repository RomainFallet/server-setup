#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mailinabox/utilities.sh"

function SetUpMailInABox () {
  InstallGit
  InstallMailInABox
}
