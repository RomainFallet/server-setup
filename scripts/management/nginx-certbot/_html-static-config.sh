#!/bin/bash

# Exit script on error
set -e

### HTML static config

# Get app name
appname=$1

# Return config
echo "root /var/www/${appname};

  index index.html;

  location / {
    try_files \$uri \$uri/ =404;
  }
"
