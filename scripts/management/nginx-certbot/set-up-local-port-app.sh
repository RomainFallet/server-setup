#!/bin/bash

set -e

if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

if [[ -z "${localport}" ]]
then
  read -r -p "Define your app running port (eg. 3000): " localport
fi

source ./_get-config-from-app-type.sh "${appname}"

nginxconfig="server {
  listen ${localport};
  listen [::]:${localport};
  server_name 127.0.0.1;

  ${nginxconfigfromapptype}

  error_log  /var/log/nginx/${appname}.error.log error;
  access_log /var/log/nginx/${appname}.access.log;

  add_header Content-Security-Policy \"default-src 'self';\";
  add_header X-Frame-Options \"deny\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Permissions-Policy \"microphone=(); geolocation=(); camera=();\";
}"
nginxconfigfile="/etc/nginx/sites-available/${appname}-localport-${localport}.conf"

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

if ! test -f /etc/nginx/sites-enabled/"${appname}-localport-${localport}".conf
then
  sudo ln -s "${nginxconfigfile}" /etc/nginx/sites-enabled/
fi

sudo service nginx restart

sudo ufw allow "${localport}"
