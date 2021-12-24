#!/bin/bash

# Exit script on error
set -e

### Set up weekly SMART test

# Install smartmontools
dpkg -s smartmontools || sudo apt install -y smartmontools

# Create script
script="#!/bin/bash
set -e
smartInfos=$(sudo smartctl --info /dev/sda)
echo \"\${smartInfos}\" | grep 'SMART support is: Enabled' || sudo smartctl --smart=on /dev/sda
sudo smartctl --test long /dev/sda
sudo smartctl --all /dev/sda
"
scriptPath=/etc/cron.weekly/smart-long-test
echo "${script}" | sudo tee "${scriptPath}" > /dev/null

# Make backup script executable
sudo chmod +x "${scriptPath}"
