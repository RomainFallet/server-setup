#!/bin/bash

function OpenFireWallPortWithUfw () {
  port="${1}"
  sudo ufw allow "${port}"
}

function EnableUfwFireWall () {
  echo 'y' | sudo ufw enable
}
