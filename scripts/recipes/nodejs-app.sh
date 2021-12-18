#!/bin/bash

# Exit script on error
set -e

### Set up a Web app

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")/..

# Ask infos
appName=${1}
if [[ -z "${appName}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appName
fi

appDomain=${2}
if [[ -z "${appDomain}" ]]
then
  read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appDomain
fi

createPostgreSQLDatabase=${3}
if [[ -z "${createPostgreSQLDatabase}" ]]
then
  read -r -p "Do you want to create a PostgreSQL database for this app? [y/N]: " createPostgreSQLDatabase
  createPostgreSQLDatabase=${createPostgreSQLDatabase:-n}
  createPostgreSQLDatabase=$(echo "${createPostgreSQLDatabase}" | awk '{print tolower($0)}')
fi

# Create PostgreSQL database
if [[ "${createPostgreSQLDatabase}" == 'y' ]]; then
  bash "${directoryPath}"/postgresql/create-app-database.sh "${appName}"
fi

# Get tls certificate
bash "${directoryPath}"/nginx-certbot/get-tls-certificate.sh "${appName}" "${appDomain}"

# Set up domain name app
bash "${directoryPath}"/nginx-certbot/set-up-domain-name-app.sh "${appName}" "${appDomain}" "1"

# Create a chroot jail to deploy this app
bash "${directoryPath}"/chroot/create-jail.sh "${appName}"

# Create a startup service
bash "${directoryPath}"/systemd/create-startup-service-with-autorestart-watcher.sh "${appName}" "/usr/bin/node /jails/${appName}/home/${appName}/index.js" "/jails/${appName}/home/${appName}/" "${appName}"
