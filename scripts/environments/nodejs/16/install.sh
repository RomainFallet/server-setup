#!/bin/bash

# Exit script on error
set -e

### NodeJS 16

# Add NodeJS official repository and update packages list
nodeSetup=$(curl -fsSL https://deb.nodesource.com/setup_16.x)
echo "${nodeSetup}" | sudo -E bash -

# Install NodeJS
sudo apt install -y nodejs

# Show NodeJS version
node -v
npm -v
