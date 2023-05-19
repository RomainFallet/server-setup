#!/bin/bash

function InstallAptPackageIfNotExisting() {
  aptPackageName="${1}"
  if ! dpkg --status "${aptPackageName}" &> /dev/null; then
    sudo apt install -y "${aptPackageName}"
  fi
}
