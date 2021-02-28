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

source ./_get-config-from-app-type.sh "${appname}"

apacheconfig="<VirtualHost *:443>
  ServerName ${appdomain}

  ${apacheconfigfromapptype}

  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined

  SSLEngine on
  SSLCertificateFile /etc/letsencrypt/live/${appdomain}/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/${appdomain}/privkey.pem

  Header set Strict-Transport-Security \"max-age=15552000; preload;\"
  Header set Expect-CT \"max-age=86400, enforce\"
  Header set Content-Security-Policy \"default-src 'self';\"
  Header set X-Frame-Options \"deny\"
  Header set X-Content-Type-Options \"nosniff\"
  Header set Referrer-Policy \"same-origin\"
  Header set Permissions-Policy \"microphone=(); geolocation=(); camera=();\"
</VirtualHost>"
apacheconfigfile="/etc/apache2/sites-available/${appname}-public-${appdomain//\./}.conf"

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

sudo a2ensite "${appname}-public-${appdomain//\./}"

sudo service apache2 restart
