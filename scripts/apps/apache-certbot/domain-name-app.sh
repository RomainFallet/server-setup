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
source ~/server-setup/scripts/apache-certbot/_config-from-app-type.sh "${appname}"

apacheconfig="<VirtualHost *:443>
  ServerName ${appdomain}
  ${apacheconfigfromapptype}
  SSLEngine on
  SSLCertificateFile /etc/letsencrypt/live/yourname-yourappname.local.tolk.ai/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/yourname-yourappname.local.tolk.ai/privkey.pem
  Header always set Stirct-Transport-Security 'max-age=15552000;'
  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined
</VirtualHost>"
apacheconfigfile="/etc/apache2/sites-available/${appname}-public-${appdomain//\./}.conf"

if [[ $(< "${apacheconfigfile}") != *"${apacheconfig}"* ]]
then
  echo "${apacheconfig}" | sudo tee "${apacheconfigfile}" > /dev/null
fi

sudo a2ensite "${appname}"

sudo service apache2 restart
