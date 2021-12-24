#!/bin/bash

# Exit script on error
set -e

### Set up a backup machine

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")/..

# Basic server setup
bash "${directoryPath}"/basic.sh

# Set up a data disk (to isolate system from user files)
bash "${directoryPath}"/disks/set-up-data-disk.sh

# Set up daily SMART test
bash "${directoryPath}"/disks/set-up-daily-smart-test.sh

# Set up weekly SMART test
bash "${directoryPath}"/disks/set-up-weekly-smart-test.sh
