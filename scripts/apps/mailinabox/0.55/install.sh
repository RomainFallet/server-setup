#!/bin/bash

# Exit script on error
set -e

### Mailinabox

# Clone repository
if ! test -d ~/mailinabox
then
  git clone https://github.com/mail-in-a-box/mailinabox  ~/mailinabox
fi

# Select version
cd ~/mailinabox
git checkout v55

# Install
sudo ./setup/start.sh
cd ~/
