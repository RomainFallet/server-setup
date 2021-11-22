#!/bin/bash

set -e

appname=$1
port=$2

echo "root /var/www/${appname};

location / {
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header Host \$host;
  proxy_set_header X-NginX-Proxy true;
  proxy_pass http://localhost:${port};
  proxy_redirect http://localhost:${port}/ https://\$server_name/;
}
"
