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
  listen 80      http2;
  listen [::]:80 http2;
  server_name ${appdomain};

  root /var/www/${appname};

  error_log  /var/log/nginx/${appname}.error.log error;
  access_log /var/log/nginx/${appname}.access.log;

  location /.well-known/acme-challenge/ {
    try_files \$uri =404;
  }
</VirtualHost>"
nginxcconfigfile="/etc/nginxc2/sites-available/${appname}-wellknown-${appdomain//\./}.conf"

if ! test -d "/var/www/${appname}"
then
  sudo mkdir "/var/www/${appname}"
fi

sudo chown www-data:www-data "/var/www/${appname}"
sudo chmod 775 "/var/www/${appname}"

if ! test -f "${nginxcconfigfile}"
then
  sudo touch "${nginxcconfigfile}"
fi

if [[ $(< "${nginxcconfigfile}") != "${nginxcconfig}" ]]
then
  echo "${nginxcconfig}" | sudo tee "${nginxcconfigfile}" > /dev/null
fi

sudo a2ensite "${appname}-wellknown-${appdomain//\./}"

sudo service nginxc2 restart

sudo certbot certonly --webroot -w "/var/www/${appname}" -d "${appdomain}" -m "${email}" -n --agree-tos
