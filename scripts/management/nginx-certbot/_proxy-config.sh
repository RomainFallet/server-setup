#!/bin/bash

set -e

appname=$1
port=$2

echo "root /var/www/${appname};

location / {
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_pass http://localhost:${port};
}
"
