#!/bin/bash

set -e

appname=$1

echo "root /var/www/${appname};

index index.html;

location / {
    try_files \$uri \$uri/ =404;
}
"
