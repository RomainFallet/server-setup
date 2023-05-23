#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/utilities.sh"

InstallGiteaPrerequisites
InstallGitea
