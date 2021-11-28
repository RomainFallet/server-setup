#!/bin/bash

# Exit script on error
set -e

### Restore dump with PostgreSQL

# Ask source path if not already set
sourcePath=$1
if [[ -z "${sourcePath}" ]]
then
  read -r -p "Enter the source path of your PostgreSQL dump file: " sourcePath
fi

# Restart PostgreSQL to close any existing connection
sudo service postgresql restart

# Restore dump
sudo -u postgres psql --set ON_ERROR_STOP=on -f "${sourcePath}"

# Restart PostgreSQL to ensure everything is OK
sudo service postgresql restart
