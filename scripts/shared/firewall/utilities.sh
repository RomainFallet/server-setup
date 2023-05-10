#!/bin/bash

function OpenFireWallPortWithUfw () {
  port="${1}"
  sudo ufw allow "${port}"
}
