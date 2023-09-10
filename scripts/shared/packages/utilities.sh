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
  sudo apt autoremove -y
  sudo apt clean
}

function CleanOldLinuxKernel () {
  # shellcheck disable=SC2312
  sudo dpkg --list | grep 'linux-image' | awk '{ print $2 }' | sort -V | sed -n '/'"$(uname -r | sed "s/\([0-9.-]*\)-\([^0-9]\+\)/\1/")"'/q;p' | xargs sudo apt purge -y
  # shellcheck disable=SC2312
  sudo dpkg --list | grep 'linux-headers' | awk '{ print $2 }' | sort -V | sed -n '/'"$(uname -r | sed "s/\([0-9.-]*\)-\([^0-9]\+\)/\1/")"'/q;p' | xargs sudo apt purge -y
}

function AddGpgKeyWithCurl () {
  keyDownloadUrl="${1}"
  keyPath="${2}"
  (curl --fail --silent --show-error --location "${keyDownloadUrl}" || true) | sudo gpg --dearmor -o "${keyPath}"
}

function ReloadAptRepositories () {
  sudo apt update
}
