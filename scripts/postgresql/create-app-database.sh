#!/bin/bash

# Exit script on error
set -e

### Create a new PostgreSQL database for an app

# Ask app name if not already set
appName=${1}
if [[ -z "${appName}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appName
fi

# Ask database name if not already set
databasePassword=$6
if [[ -z "${databasePassword}" ]]
then
  read -r -p "Choose your database password: " databasePassword
fi

# Get existing databases & users list
databasesList=$(sudo -u postgres psql -l)
usersList=$(sudo -u postgres psql -c "\du+")

# Create database
echo "${databasesList}" | grep "${appName}" || sudo -u postgres psql -c "CREATE DATABASE ${appName};"

# Create user
echo "${usersList}"  | grep "${appName}" || sudo -u postgres psql -d "${appName}" -c "CREATE USER ${appName};"

# Set user password
sudo -u postgres psql -d "${appName}" -c "ALTER USER \"${appName}\" with encrypted password '${databasePassword}';"

# Give access to the created database
sudo -u postgres psql -d "${appName}" -c "GRANT ALL PRIVILEGES ON DATABASE \"${appName}\" TO \"${appName}\";"
