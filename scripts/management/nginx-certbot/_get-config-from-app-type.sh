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
    - PHP/Owncloud:                     [1]
  Your choice: " apptype
fi

if [[ "${apptype}" == '1' ]]
then
  # shellcheck disable=SC2034
  nginxconfigfromapptype="root /var/www/${appname};

  index index.php index.html /index.php\$request_uri;

  location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
  location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)              { return 404; }

  location ~ \.php(?:$|/) {
    include fastcgi_params;
    fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
    try_files \$fastcgi_script_name =404;
  }

  location / {
      try_files \$uri \$uri/ /index.php\$request_uri;
  }

  location ^~ /.well-known {
    location = /.well-known/carddav     { return 301 /remote.php/dav/; }
    location = /.well-known/caldav      { return 301 /remote.php/dav/; }
    location ^~ /.well-known            { return 301 /index.php\$uri; }
    try_files  \$uri \$uri/ =404;
  }
  "

fi
