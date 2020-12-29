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

apacheconfig="<VirtualHost *:80>
  ServerName ${appdomain}
  DocumentRoot /var/www/${appname}

  <Directory /var/www/${appname}>
    Require all denied
  </Directory>

  <Directory /var/www/${appname}/.well-known/acme-challenge>
    Require all granted
    Options -Indexes -FollowSymLinks
    AllowOverride None
  </Directory>

  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined

  RewriteEngine on
  RewriteRule ^\/.well-known\/acme-challenge\/.+$ - [END]
  RewriteRule ^.+$ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>"
apacheconfigfile="/etc/apache2/sites-available/${appname}-wellknown-${appdomain//\./}.conf"

if ! sudo grep "${apacheconfig}" "${apacheconfigfile}" > /dev/null
then
  echo "${apacheconfig}" | sudo tee "${apacheconfigfile}" > /dev/null
fi

sudo a2ensite "${appname}-wellknown-${appdomain//\./}"

sudo service apache2 restart

sudo certbot certonly --webroot -w "/var/www/${appname}" -d "${appdomain}" -m "${email}" -n --agree-tos
