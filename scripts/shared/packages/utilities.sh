#!/bin/bash

function InstallAptPackageIfNotExisting() {
  aptPackageName="${1}"
  if ! dpkg --status "${aptPackageName}" &> /dev/null; then
    sudo apt install -y "${aptPackageName}"
  fi
}

function UpgradeAllAptPackages () {
  sudo apt update
  sudo apt dist-upgrade -y
}
