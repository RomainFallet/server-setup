#!/bin/bash

# Exit script on error
set -e

### Set up daily SMART test

# Install smartmontools
dpkg -s smartmontools &> /dev/null || sudo apt install -y smartmontools

# Create script
script="#!/bin/bash
set -e
smartInfos=$(sudo smartctl --info /dev/sda)
echo \"\${smartInfos}\" | grep 'SMART support is: Enabled' || sudo smartctl --smart=on /dev/sda
sudo smartctl --test short /dev/sda
sudo smartctl --all /dev/sda
"
scriptPath=/etc/cron.daily/smart-short-test
echo "${script}" | sudo tee "${scriptPath}" > /dev/null

# Make backup script executable
sudo chmod +x "${scriptPath}"
