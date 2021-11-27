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
    proxy_pass http://localhost:${port};
  }
"
