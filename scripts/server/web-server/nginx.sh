#!/bin/bash

# Exit script on error
set -e

### Nginx web server

# Install
sudo apt install -y nginx

# Remove default site
sudo rm -rf /var/www/html

# Create config file
fail2banconfigfile=/etc/fail2ban/jail.local
if ! test -f "${fail2banconfigfile}"
then
  sudo touch /etc/fail2ban/jail.local
fi

# Fail2ban config
fail2banconfig="
[nginx-http-auth]
enabled  = true
port     = http,https
filter   = nginx-http-auth
logpath  = /var/log/nginx/*error.log
maxretry = 6"
fail2banconfigfile=/etc/fail2ban/jail.local
pattern=$(echo "${fail2banconfig}" | tr -d '\n')
content=$(< "${fail2banconfigfile}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${fail2banconfig}" | sudo tee -a "${fail2banconfigfile}" > /dev/null
fi

# Restart Fail2ban
sudo service fail2ban restart

# Show Nginx version
nginx -v

# Allow Nginx connections
sudo ufw allow 'Nginx Full'

### Certbot

# Install
sudo snap install --classic certbot

# Show Certbot version
certbot --version
