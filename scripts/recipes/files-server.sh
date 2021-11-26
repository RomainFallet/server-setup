#!/bin/bash

# Exit script on error
set -e

### Set up a files server

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")

# Basic server setup
bash "${directoryPath}"/../server/basic.sh

# Install Samba
bash "${directoryPath}"/../server/file-server/samba/install.sh

# Set up a data disk (to isolate system from user files)
bash "${directoryPath}"/../management/disks/set-up-data-disk.sh

# Create a shared Samba folder
bash "${directoryPath}"/../management/samba/create-shared-access.sh /mnt/sda/shared

# Create a personal Samba folder for each user
bash "${directoryPath}"/../management/samba/create-users-access.sh
