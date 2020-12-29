#!/bin/bash

# Exit script on error
set -e

### Apache web server

# Install
sudo apt install -y apache2 libapache2-mod-fcgid

# Enable modules
sudo a2enmod ssl rewrite proxy proxy_http headers actions fcgid alias proxy_fcgi

# Backup config file
apacheenvarsconfigpath=/etc/apache2/envvars
apacheenvarsconfigbackuppath=/etc/apache2/.envvars.backup
if ! test -f "${apacheenvarsconfigbackuppath}"
then
  sudo cp "${apacheenvarsconfigpath}" "${apacheenvarsconfigbackuppath}"
fi

# Set umask of the Apache user
umaskconfig='umask 002'
if ! sudo grep "^${umaskconfig}" "${apacheenvarsconfigpath}" > /dev/null
then
  echo "${umaskconfig}" | sudo tee -a "${apacheenvarsconfigpath}" > /dev/null
fi

# Disable default site
sudo a2dissite 000-default.conf

# Restart Apache
sudo service apache2 restart

# Fail2ban config
fail2banconfig="
[apache]
enabled  = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
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

# Show Apache version
apache2 -v

# Show Apache modules
sudo apache2ctl -M

# Allow Apache connections
sudo ufw allow 'Apache Full'

### Certbot

# Install
sudo snap install --classic certbot

# Show Certbot version
certbot --version
