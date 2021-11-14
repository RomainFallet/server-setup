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
    - HTML/Static:                     [1]
  Your choice: " apptype
fi

if [[ "${apptype}" == '1' ]]
then
  # shellcheck disable=SC2034
  nginxconfigfromapptype="root /var/www/${appname};

  index index.html /index.php\$request_uri;

  location / {
      try_files \$uri \$uri/ =404;
  }
  "
fi
