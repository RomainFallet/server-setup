#!/bin/bash

# Exit script on error
set -e

### Set up a mail machine

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")/..

# Basic server setup
bash "${directoryPath}"/basic.sh

# Install Mailinabox
bash "${directoryPath}"/apps/mailinabox/0.55/install.sh

# Ask to restore backup if not already set
restoreBackup=$1
if [[ -z "${restoreBackup}" ]]
then
  read -r -p "Restore data from pre-existing remote backup? [y/N]: " restoreBackup
  restorebackup=${restoreBackup:-n}
  restorebackup=$(echo "${restoreBackup}" | awk '{print tolower($0)}')
fi

if [[ "${restorebackup}" == 'y' ]]
then
  # Restore backup
  # shellcheck disable=SC2088
  bash "${directoryPath}"/rsync/restore-backup.sh "/home/user-data" "~/data/"

  # Restart Mailinabox install
  sudo mailinabox
fi

# Set up daily backups
# shellcheck disable=SC2088
bash "${directoryPath}"/rsync/set-up-daily-backup.sh "/home/user-data/" "~/data"
