#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/utilities.sh"

InstallGiteaPrerequisites
InstallGitea
