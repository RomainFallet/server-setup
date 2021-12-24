#!/bin/bash

# Exit script on error
set -e

### ProtonVPN

# Add official repository
if ! test -f /etc/apt/sources.list.d/protonvpn-stable.list; then
  wget https://protonvpn.com/download/protonvpn-stable-release_1.0.1-1_all.deb -P /tmp
  sudo apt install /tmp/protonvpn-stable-release_1.0.1-1_all.deb
  sudo apt update
  sudo rm /tmp/protonvpn-stable-release_1.0.1-1_all.deb
fi

# Install
dpkg -s protonvpn-cli &> /dev/null || sudo apt install -y protonvpn-cli

# Ask protonvpn username
username=${1}
if [[ -z "${username}" ]]
then
  read -r -p "Enter your ProtonVPN username: " username
fi

# Login
protonvpn-cli login "${username}"

# Connect
protonvpn-cli connect -f

# Enable kill-switch
protonvpn-cli ks --permanent
