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

# Create a new UNIX user with in postgres group
posgresGroupInfos=$(getent group postgres)
postgresGroupId=$(echo "${posgresGroupInfos}" | cut -d: -f3)
sudo useradd temporary_superadmin -g "${postgresGroupId}"

# Create a new temporary super user role
sudo -u postgres psql -c "CREATE ROLE temporary_superadmin LOGIN SUPERUSER;"
sudo -u postgres psql -c "CREATE DATABASE temporary_superadmin;"

# Restore dump
sudo -u temporary_superadmin psql --set ON_ERROR_STOP=on -f "${sourcePath}"

# Remove temporary super user
sudo -u postgres psql -c "DROP ROLE temporary_superadmin;"
sudo -u postgres psql -c "DROP DATABASE temporary_superadmin;"
sudo userdel temporary_superadmin

# Vaccumm and restart PostgreSQL to ensure everything is OK
sudo -u postgres vacuumdb -a -z
sudo service postgresql restart
