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

# Restore dump
sudo -u postgres psql --set ON_ERROR_STOP=on -f "${sourcePath}"
