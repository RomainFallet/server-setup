#!/bin/bash

# shellcheck source=./utilities.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/firewall/utilities.sh"

function OpenFireWallPort () {
  port="${1}"
  OpenFireWallPortWithUfw "${port}"
}

function EnableFireWall () {
  EnableUfwFireWall
}
