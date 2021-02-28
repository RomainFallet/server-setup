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

apacheconfig="Listen ${localport}
<VirtualHost *:${localport}>
  ServerName 127.0.0.1

  ${apacheconfigfromapptype}

  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined

  Header set Content-Security-Policy \"default-src 'self' 'unsafe-inline';\"
  Header set X-Frame-Options \"deny\"
  Header set X-Content-Type-Options \"nosniff\"
  Header set Referrer-Policy \"same-origin\"
  Header set Permissions-Policy \"microphone=(); geolocation=(); camera=();\"
</VirtualHost>"
apacheconfigfile="/etc/apache2/sites-available/${appname}-localport-${localport}.conf"

if ! test -d "/var/www/${appname}"
then
  sudo mkdir "/var/www/${appname}"
fi

sudo chown www-data:www-data "/var/www/${appname}"
sudo chmod 775 "/var/www/${appname}"

if ! test -f "${apacheconfigfile}"
then
  sudo touch "${apacheconfigfile}"
fi

if [[ $(< "${apacheconfigfile}") != "${apacheconfig}" ]]
then
  echo "${apacheconfig}" | sudo tee "${apacheconfigfile}" > /dev/null
fi

sudo a2ensite "${appname}-localport-${localport}"

sudo service apache2 restart

sudo ufw allow "${localport}"
