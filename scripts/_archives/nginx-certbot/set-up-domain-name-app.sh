#!/bin/bash

# Exit script on error
set -e

### Set up domain name app

# Get current directory path
filePath=$(realpath -s "${0}")
directoryPath=$(dirname "${filePath}")

# Ask app name if not already set
appName=${1}
if [[ -z "${appName}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appName
fi

# Ask app domain if not already set
appDomain=${2}
if [[ -z "${appDomain}" ]]
then
  read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appDomain
fi

# Ask app type if not already set
appType=${3}
if [[ -z "${appType}" ]]
then
  read -r -p "Which type of app do you want to deploy?
    - Proxy to a local IP/port:        [1]
    - HTML/Static:                     [2]
  Your choice: " appType
fi

# Get proxy config
if [[ "${appType}" == '1' ]]
then
  appPort=${4}
  if [[ -z "${appIp}" ]]
  then
    read -r -p "Enter your local IP address: " appIp
  fi

  appPort=${5}
  if [[ -z "${appPort}" ]]
  then
    read -r -p "Enter your local app port: " appPort
  fi
  nginxConfigFromAppType=$(bash "${directoryPath}"/_proxy-config.sh "${appName}" "${appIp}" "${appPort}")

# Get HTML/static
elif [[ "${appType}" == '2' ]]
then
  nginxConfigFromAppType=$(bash "${directoryPath}"/_html-static-config.sh "${appName}")
fi

# Create HTTPS config
nginxConfig="server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${appDomain};

  ${nginxConfigFromAppType}

  error_log  /var/log/nginx/${appName}.error.log error;
  access_log /var/log/nginx/${appName}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${appDomain}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${appDomain}/privkey.pem;

  add_header Strict-Transport-Security \"max-age=15552000; preload;\";
  add_header Expect-CT \"max-age=86400, enforce\";
  add_header Content-Security-Policy \"default-src 'self';\";
  add_header X-Frame-Options \"deny\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Cache-Control \"private, max-age=604800, must-revalidate\";
  add_header Permissions-Policy \"fullscreen=(self); microphone=(); geolocation=(); camera=(); midi=(); sync-xhr=(); magnetometer=(); gyroscope=(); payment=();\";
}"
nginxConfigPath="/etc/nginx/sites-available/${appName}-public-${appDomain//\./}.conf"
echo "${nginxConfig}" | sudo tee "${nginxConfigPath}" > /dev/null

# Enable Nginx config
if ! test -f /etc/nginx/sites-enabled/"${appName}-public-${appDomain//\./}".conf
then
  sudo ln -s "${nginxConfigPath}" /etc/nginx/sites-enabled/
fi

# For all apps except proxy
if [[ "${appType}" != '1' ]]
then
  # Create app directory
  if ! test -d "/var/www/${appName}"
  then
    sudo mkdir "/var/www/${appName}"
  fi

  # Set permissions
  sudo chown www-data:www-data "/var/www/${appName}"
  sudo chmod 775 "/var/www/${appName}"
fi

# Restart Nginx
sudo service nginx restart
