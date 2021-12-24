#!/bin/bash

# Exit script on error
set -e

### NodeJS 16

# Add NodeJS official repository and update packages list
nodeSetup=$(curl -fsSL https://deb.nodesource.com/setup_16.x)
test -f /etc/apt/sources.list.d/nodesource.list || echo "${nodeSetup}" | sudo -E bash -

# Install NodeJS
dpkg -s nodejs &> /dev/null || sudo apt install -y nodejs
