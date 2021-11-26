#!/bin/bash

# Exit script on error
set -e

### Get TLS certificates

# Ask app name if not already set
appName=${1}
if [[ -z "${appName}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appName
fi

# Ask email if not already set
email=${2}
if [[ -z "${email}" ]]
then
  read -r -p "Enter your email (needed to request TLS certificate): " email
fi

# Ask app domain if not already set
appDomain=${3}
if [[ -z "${appDomain}" ]]
then
  read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appDomain
fi

# Create HTTP config for ACME challenge
nginxConfig="server {
  listen 80;
  listen [::]:80;
  server_name ${appDomain};

  root /var/www/${appName};

  error_log  /var/log/nginx/${appName}.error.log error;
  access_log /var/log/nginx/${appName}.access.log;

  location /.well-known/acme-challenge/ {
    try_files \$uri =404;
  }
  location / {
    return 301 https://\$host\$request_uri;
  }
}"
nginxConfigPath="/etc/nginx/sites-available/${appName}-wellknown-${appDomain//\./}.conf"
pattern=$(echo "${nginxConfig}" | tr -d '\n')
content=$(< "${nginxConfigPath}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${nginxConfig}" | sudo tee "${nginxConfigPath}" > /dev/null
fi

# Enable Nginx config
if ! test -f /etc/nginx/sites-enabled/"${appName}-wellknown-${appDomain//\./}".conf
then
  sudo ln -s "${nginxConfigPath}" /etc/nginx/sites-enabled/
fi

# Create app directory
if ! test -d "/var/www/${appName}"
then
  sudo mkdir "/var/www/${appName}"
fi

# Set permissions
sudo chown www-data:www-data "/var/www/${appName}"
sudo chmod 775 "/var/www/${appName}"

# Restart Nginx
sudo service nginx restart

# Generate certificate
sudo certbot certonly --webroot -w "/var/www/${appName}" -d "${appDomain}" -m "${email}" -n --agree-tos
