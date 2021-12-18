#!/bin/bash

# Exit script on error
set -e

### Proxy config

# Get app name & port
appname=${1}
port=${2}

# Return config
echo "root /var/www/${appname};

  location / {
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass http://127.0.0.1:${port};
  }
"
