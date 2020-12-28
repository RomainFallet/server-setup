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

# shellcheck source=_config-from-app-type.sh
source ~/server-setup/scripts/apache/_config-from-app-type.sh "${appname}"

apacheconfig="Listen ${localport}
<VirtualHost *:${localport}>
  ServerName 127.0.0.1
  ${apacheconfigfromapptype}
  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined
</VirtualHost>"
apacheconfigfile="/etc/apache2/sites-available/${appname}-localport-${localport}.conf"

if ! sudo grep "${apacheconfig}" "${apacheconfigfile}" > /dev/null
then
  echo "${apacheconfig}" | sudo tee "${apacheconfigfile}" > /dev/null
fi

sudo a2ensite "${appname}"

sudo service apache2 restart

sudo ufw allow "${localport}"
