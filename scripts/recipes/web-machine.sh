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
  bash "${directoryPath}"/rsync/restore-backup.sh /home/user-data/

  # Restore Nginx & Letsencrypt dump
  bash "${directoryPath}"/nginx-certbot/restore-dump.sh /home/user-data

  # Restart Nginx
  sudo services nginx restart

  # Restore PostgreSQL dump
  bash "${directoryPath}"/postgresql/restore-dump.sh /home/user-data/postgresql14-dump.sql

  # Restart PostgreSQL
  sudo services postgresql restart
fi

# Set up daily dumps
bash "${directoryPath}"/postgesql/set-up-daily-dump.sh /home/user-data/postgresql14-dump.sql
bash "${directoryPath}"/nginx-cerbot/set-up-daily-dump.sh /home/user-data

# Set up daily backups
bash "${directoryPath}"/rsync/set-up-daily-backup.sh /home/user-data
