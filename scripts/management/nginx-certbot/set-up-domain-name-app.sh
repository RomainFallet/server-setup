#!/bin/bash

set -e

appname=$1
if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

appdomain=$2
if [[ -z "${appdomain}" ]]
then
  read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appdomain
fi

apptype=$3
if [[ -z "${apptype}" ]]
then
  read -r -p "Which type of app do you want to deploy?
    - Proxy to a local port:           [1]
    - HTML/Static:                     [2]
  Your choice: " apptype
fi

if [[ "${apptype}" == '1' ]]
then
  appport=$4
  if [[ -z "${appport}" ]]
  then
    read -r -p "Enter your local app port: " appport
  fi
  nginxconfigfromapptype=$(bash ~/server-setup/scripts/management/nginx-certbot/_proxy-config.sh "${appname}" "${appport}")
elif [[ "${apptype}" == '2' ]]
then
  nginxconfigfromapptype=$(bash ~/server-setup/scripts/management/nginx-certbot/_html-static-config.sh "${appname}")
fi

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
nginxconfigfile="/etc/nginx/sites-available/${appname}-public-${appdomain//\./}.conf"

if [[ "${apptype}" != '1' ]]
then
  if ! test -d "/var/www/${appname}"
  then
    sudo mkdir "/var/www/${appname}"
  fi

  sudo chown www-data:www-data "/var/www/${appname}"
  sudo chmod 775 "/var/www/${appname}"
fi

if ! test -f "${nginxconfigfile}"
then
  sudo touch "${nginxconfigfile}"
fi

if [[ $(< "${nginxconfigfile}") != "${nginxconfig}" ]]
then
  echo "${nginxconfig}" | sudo tee "${nginxconfigfile}" > /dev/null
fi

if ! test -f /etc/nginx/sites-enabled/"${appname}-public-${appdomain//\./}".conf
then
  sudo ln -s "${nginxconfigfile}" /etc/nginx/sites-enabled/
fi

sudo service nginx restart
