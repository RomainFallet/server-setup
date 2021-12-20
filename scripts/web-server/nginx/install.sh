#!/bin/bash

# Exit script on error
set -e

### Nginx web server

# Install
dpkg -s nginx > /dev/null || sudo apt install -y nginx

# Backup config file
nginxConfigPath=/etc/nginx/nginx.conf
nginxConfigBackupPath=/etc/nginx/.nginx.conf.backup
if ! test -f "${nginxConfigBackupPath}"
then
  sudo cp "${nginxConfigPath}" "${nginxConfigBackupPath}"
fi

# Set server_tokens directive
sudo sed -i'.tmp' -E "s/#*\s*server_tokens\s+\w+;/server_tokens off;/g" "${nginxConfigPath}"

# Disable default site
sudo rm -f /etc/nginx/sites-enabled/default

# Remove default site
sudo rm -rf /var/www/html

# Restart Nginx
sudo service nginx restart

# Create config file
fail2banConfigPath=/etc/fail2ban/jail.local
if ! test -f "${fail2banConfigPath}"
then
  sudo touch /etc/fail2ban/jail.local
fi

# Fail2ban config
fail2banConfig="
[nginx-http-auth]
enabled  = true
port     = http,https
filter   = nginx-http-auth
logpath  = /var/log/nginx/*error.log
maxretry = 6"
pattern=$(echo "${fail2banConfig}" | tr -d '\n')
content=$(< "${fail2banConfigPath}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${fail2banConfig}" | sudo tee -a "${fail2banConfigPath}" > /dev/null
fi

# Restart Fail2ban
sudo service fail2ban restart

# Show Nginx version
nginx -v

# Allow Nginx connections
sudo ufw allow 'Nginx Full'

### Certbot

# Install
snapPackages=$(snap list)
echo "${snapPackages}" | grep 'certbot' || sudo snap install --classic certbot

# Show Certbot version
certbot --version
