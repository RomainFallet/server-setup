#!/bin/bash

set -e

appname=$1
if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

if [[ -z "${apptype}" ]]
then
  read -r -p "Which type of app do you want to deploy?
    - Proxy to a local port:             [1]
    - Proxy to a local port (Nextcloud): [2]
    - HTML only                          [3]
    - JS/React/Angular:                  [4]
    - PHP/Symfony:                       [5]
    - PHP/Nextcloud:                     [6]
  Your choice: " apptype
fi

if [[ "${apptype}" == '1' ]]
then
  if [[ -z "${proxyport}" ]]
  then
    read -r -p "Enter the local port to proxy your requests to (eg. 3100): " proxyport
  fi

  apacheconfigfromapptype="ProxyPass / http://127.0.0.1:${proxyport}/"
fi

if [[ "${apptype}" == '2' ]]
then
  if [[ -z "${proxyport}" ]]
  then
    read -r -p "Enter the local port to proxy your requests to (eg. 3100): " proxyport
  fi

  apacheconfigfromapptype="ProxyPass / http://127.0.0.1:${proxyport}/

  RewriteEngine On
  RewriteRule ^/\.well-known/carddav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
  RewriteRule ^/\.well-known/caldav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]"
fi

if [[ "${apptype}" == '3' ]]
then
  apacheconfigfromapptype="DocumentRoot /var/www/${appname}

  <Directory /var/www/${appname}>
    Require all granted
    Options -Indexes -FollowSymLinks
    AllowOverride None
  </Directory>"
fi

if [[ "${apptype}" == '4' ]]
then
  apacheconfigfromapptype="DocumentRoot /var/www/${appname}

  <Directory /var/www/${appname}>
    Require all granted
    Options -Indexes -FollowSymLinks
    AllowOverride None
    RewriteEngine on
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteRule ^ index.html [QSA,L]
  </Directory>"
fi

if [[ "${apptype}" == '5' ]]
then
  if ! test -d "/var/www/${appname}/tmp"
  then
    sudo mkdir "/var/www/${appname}/tmp"
  fi
  apacheconfigfromapptype="DocumentRoot /var/www/${appname}

  <Directory /var/www/${appname}/public>
    Require all granted
    Options -Indexes -FollowSymLinks
    AllowOverride None
    php_admin_value open_basedir '/var/www/${appname}'
    php_admin_value upload_tmp_dir '/var/www/${appname}/tmp'
    FallbackResource /index.php
  </Directory>
  <Directory /var/www/${appname}/public/bundles>
    FallbackResource disabled
  </Directory>

  <FilesMatch \.php$>
    SetHandler 'proxy:unix:/run/php/php7.3-fpm.sock|fcgi://localhost'
  </FilesMatch>"
fi

if [[ "${apptype}" == '6' ]]
then
  # shellcheck disable=SC2034
  apacheconfigfromapptype="DocumentRoot /var/www/${appname}

  <Directory /var/www/${appname}>
    Require all granted
    Options +FollowSymLinks +MultiViews
    AllowOverride All
    php_admin_value open_basedir '/var/www/${appname}'
    php_admin_value upload_tmp_dir '/var/www/${appname}/tmp'
  </Directory>
  <IfModule mod_dav.c>
    Dav off
  </IfModule>

  <FilesMatch \.php$>
    SetHandler 'proxy:unix:/run/php/php7.3-fpm.sock|fcgi://localhost'
  </FilesMatch>"
fi
