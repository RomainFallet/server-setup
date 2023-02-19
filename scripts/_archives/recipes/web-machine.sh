#!/bin/bash

# Exit script on error
set -e

### Set up a web machine

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")/..

# Basic server setup
bash "${directoryPath}"/basic.sh

# Install Nginx
bash "${directoryPath}"/web-server/nginx/install.sh

# Install NodeJS
bash "${directoryPath}"/environments/nodejs/16/install.sh

# Install PostgreSQL
bash "${directoryPath}"/databases/postgresql/14/install.sh

# Ask to restore backup if not already set
restoreBackup=$1
if [[ -z "${restoreBackup}" ]]
then
  read -r -p "Restore data from pre-existing remote backup? [y/N]: " restoreBackup
  restorebackup=${restoreBackup:-n}
  restorebackup=$(echo "${restoreBackup}" | awk '{print tolower($0)}')
fi

# Define dump directory
sudo mkdir -p /home/user-data

if [[ "${restorebackup}" == 'y' ]]
then
  # Restore backup
  # shellcheck disable=SC2088
  bash "${directoryPath}"/rsync/restore-backup.sh "/home/user-data/" "~/data/"

  # Restore Nginx & Letsencrypt dump
  bash "${directoryPath}"/nginx-certbot/restore-dump.sh "/home/user-data"

  # Restore PostgreSQL dump
  bash "${directoryPath}"/postgresql/restore-dump.sh "/home/user-data/postgresql-dump.sql"
fi

# Set up daily dumps
bash "${directoryPath}"/postgresql/set-up-daily-dump.sh "/home/user-data/postgresql-dump.sql"
bash "${directoryPath}"/nginx-certbot/set-up-daily-dump.sh "/home/user-data"

# Set up daily backups
# shellcheck disable=SC2088
bash "${directoryPath}"/rsync/set-up-daily-backup.sh "/home/user-data/" "~/data/"
