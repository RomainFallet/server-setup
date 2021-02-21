#!/bin/bash

set -e

if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

if [[ -z "${appdomain}" ]]
then
  read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appdomain
fi

# shellcheck source=_config-from-app-type.sh
source ~/server-setup/scripts/apps/nginx-certbot/_config-from-app-type.sh "${appname}"

nginxconfig="server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${appdomain};

  ${nginxconfigfromapptype}

  error_log  /var/log/nginx/${appname}.error.log error;
  access_log /var/log/nginx/${appname}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${appdomain}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${appdomain}/privkey.pem;

  add_header Strict-Transport-Security \"max-age=15552000; preload;\";
  add_header Expect-CT \"max-age=86400, enforce\";
  add_header Content-Security-Policy \"default-src 'self';\";
  add_header X-Frame-Options \"deny\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Permissions-Policy \"microphone=(); geolocation=(); camera=();\";
}"
nginxconfigfile="/etc/nginx/conf.d/${appname}-public-${appdomain//\./}.conf"

if ! test -d "/var/www/${appname}"
then
  sudo mkdir "/var/www/${appname}"
fi

sudo chown www-data:www-data "/var/www/${appname}"
sudo chmod 775 "/var/www/${appname}"

if ! test -f "${nginxconfigfile}"
then
  sudo touch "${nginxconfigfile}"
fi

if [[ $(< "${nginxconfigfile}") != "${nginxconfig}" ]]
then
  echo "${nginxconfig}" | sudo tee "${nginxconfigfile}" > /dev/null
fi

sudo service nginx restart
