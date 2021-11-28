#!/bin/bash

# Exit script on error
set -e

### Set up daily dump of Nginx config and websites and Letsencrypt config

# Ask destination path if not already set
destinationPath=${1}
if [[ -z "${destinationPath}" ]]
then
  read -r -p "Enter the destination path of your Nginx & Letsencrypt dump: " destinationPath
fi

# Ask health checks uuid if not already set
healthChecksUuid=${2}
if [[ -z "${healthChecksUuid}" ]]
then
  read -r -p "Enter your healthchecks.io uuid to monitor your Nginx & Letsencrypt dump job (optional): " healthChecksUuid
fi

# Health checks ping command
healthChecksMonitorCommand=""
if [[ -n "${healthChecksUuid}" ]]
then
  healthChecksMonitorCommand="curl -m 10 --retry 5 https://hc-ping.com/${healthChecksUuid}"
fi

# Create dump script
dumpScript="#!/bin/bash
set -e
sudo rm -rf ${destinationPath}/www ${destinationPath}/nginx ${destinationPath}/letsencrypt
sudo cp --archive /var/www ${destinationPath}/www
sudo cp --archive /etc/nginx ${destinationPath}/nginx
sudo cp --archive /etc/letsencrypt ${destinationPath}/letsencrypt
${healthChecksMonitorCommand}"
dumpScriptPath=/etc/cron.daily/postgresql-dump
if ! test -f "${dumpScriptPath}"
then
  sudo touch "${dumpScriptPath}"
fi
pattern=$(echo "${dumpScript}" | tr -d '\n')
content=$(< "${dumpScriptPath}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${dumpScript}" | sudo tee "${dumpScriptPath}" > /dev/null
fi

# Make dump script executable
sudo chmod +x "${dumpScriptPath}"