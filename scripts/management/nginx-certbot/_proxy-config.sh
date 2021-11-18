#!/bin/bash

set -e

appname=$1
port=$2

echo "root /var/www/${appname};

location / {
    proxy_pass http://localhost:${port};
}
"
