#!/bin/bash

# Exit script on error
set -e

### Proxy config

# Get app name, port & IP
appname=${1}
ip=${2}
port=${3}
if [[ "${port}" == '443' ]]; then
  proxyUrl=https://${ip}:${port};
else
  proxyUrl=http://${ip}:${port};
fi

# Return config
echo "root /var/www/${appname};

  location / {
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass ${proxyUrl};
  }
"