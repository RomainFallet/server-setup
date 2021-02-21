#!/bin/bash

set -e

if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

if [[ -z "${email}" ]]
then
  read -r -p "Enter your email (needed to request TLS certificate): " email
fi

if [[ -z "${appdomain}" ]]
then
  read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appdomain
fi

nginxcconfig="server {
  listen 80;
  listen [::]:80;
  server_name ${appdomain};

  root /var/www/${appname};

  error_log  /var/log/nginx/${appname}.error.log error;
  access_log /var/log/nginx/${appname}.access.log;

  location /.well-known/acme-challenge/ {
    try_files \$uri =404;
  }
  location / {
    return 301 https://\$host\$request_uri;
  }
}"
nginxconfigfile="/etc/nginx/sites-available/${appname}-wellknown-${appdomain//\./}.conf"

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

if [[ $(< "${nginxconfigfile}") != "${nginxcconfig}" ]]
then
  echo "${nginxcconfig}" | sudo tee "${nginxconfigfile}" > /dev/null
fi

if ! test -f /etc/nginx/sites-enabled/"${appname}-wellknown-${appdomain//\./}".conf
then
  sudo ln -s "${nginxconfigfile}" /etc/nginx/sites-enabled/
fi

sudo service nginx restart

sudo certbot certonly --webroot -w "/var/www/${appname}" -d "${appdomain}" -m "${email}" -n --agree-tos
