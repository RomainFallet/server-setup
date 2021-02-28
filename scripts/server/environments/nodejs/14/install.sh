#!/bin/bash

### NodeJS 14

# Add NodeJS official repository and update packages list
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -

# Install
sudo apt install -y nodejs

# Install PM2 process manager
sudo npm install -g pm2@~4.5.0

# Show NodeJS version
node -v
npm -v

# Show PM2 version
pm2 -v
