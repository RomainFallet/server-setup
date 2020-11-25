#!/bin/bash

# Exit script on error
set -e

### Apache web server

# Install
sudo apt install -y apache2

# Enable modules
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod headers

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
fail2banconfig+="[apache]
enabled  = true
port     = http,https
filter   = apache-auth
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-noscript]
enabled  = true
port     = http,https
filter   = apache-noscript
logpath  = /var/log/apache*/*error.log
maxretry = 6

[apache-overflows]
enabled  = true
port     = http,https
filter   = apache-overflows
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-nohome]
enabled  = true
port     = http,https
filter   = apache-nohome
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-botsearch]
enabled  = true
port     = http,https
filter   = apache-botsearch
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-shellshock]
enabled  = true
port     = http,https
filter   = apache-shellshock
logpath  = /var/log/apache*/*error.log
maxretry = 2

[apache-fakegooglebot]
enabled  = true
port     = http,https
filter   = apache-fakegooglebot
logpath  = /var/log/apache*/*error.log
maxretry = 2

[php-url-fopen]
enabled = true
port    = http,https
filter  = php-url-fopen
logpath = /var/log/apache*/*access.log
"
fail2banconfigfile=/etc/fail2ban/jail.local

if ! sudo grep "${fail2banconfig}" "${fail2banconfigfile}" > /dev/null
then
  echo "${fail2banconfig}" | sudo tee -a "${fail2banconfigfile}" > /dev/null
fi

# Restart Fail2ban
sudo service fail2ban restart

# Show Apache version
apache2 -v

# Show Apache modules
sudo apache2ctl -M

### Certbot

# Add Certbot official repositories
sudo add-apt-repository universe
sudo add-apt-repository -y ppa:certbot/certbot

# Install
sudo apt install -y certbot

# Show Certbot version
certbot --version
