#!/bin/bash

# Exit script on error
set -e

### Set up a file machine

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")/..

# Basic server setup
bash "${directoryPath}"/basic.sh

# Install Samba
bash "${directoryPath}"/file-server/samba/install.sh

# Set up a data disk (to isolate system from user files)
bash "${directoryPath}"/disks/set-up-data-disk.sh

# Set up daily SMART test
bash "${directoryPath}"/disks/set-up-daily-smart-test.sh

# Set up weekly SMART test
bash "${directoryPath}"/disks/set-up-weekly-smart-test.sh

# Create a shared Samba folder
bash "${directoryPath}"/samba/create-shared-access.sh /mnt/sda/shared

# Create a personal Samba folder for each user
bash "${directoryPath}"/samba/create-users-access.sh

# Set up daily backups
# shellcheck disable=SC2088
bash "${directoryPath}"/rsync/set-up-daily-backup.sh "/mnt/sda/" "~/data/"
