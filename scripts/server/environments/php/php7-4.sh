#!/bin/bash

### PHP 7.4

# Exit script on error
set -e

# Add PHP official repository
sudo add-apt-repository -y ppa:ondrej/php

# Install PHP
sudo apt install -y php7.4 php7.4-fpm

# Install Redis for PHP cache
sudo apt install -y redis-server

# Install extensions
sudo apt install -y php7.4-mbstring php7.4-mysql php7.4-xml php7.4-curl php7.4-zip php7.4-intl php7.4-gd php7.4-bcmath php7.4-gmp php-redis php-imagick

# Make a backup of the config file
phpinipath=/etc/php/7.4/fpm/php.ini
sudo cp "${phpinipath}" "$(dirname "${phpinipath}")/.php.ini.backup"

# Update some configuration in php.ini
sudo sed -i'.tmp' -E 's/;*\s*post_max_size\s=\s*[0-8]+M/post_max_size = 64M/g' "${phpinipath}"
sudo sed -i'.tmp' -E 's/;*\s*upload_max_filesize\s=\s*[0-8]+M/upload_max_filesize = 64M/g' "${phpinipath}"
sudo sed -i'.tmp' -E 's/;*\s*memory_limit\s=\s*-*[0-8]+M*/memory_limit = 512M/g' "${phpinipath}"

# Disable functions that can causes security breaches
sudo sed -i'.tmp' -E 's/;*\s*disable_functions\s=\s*(\w+)/disable_functions = error_reporting,ini_set,exec,passthru,shell_exec,system,proc_open,popen,parse_ini_file,show_source/g' "${phpinipath}"

# Remove temporary file
sudo rm "${phpinipath}.tmp"

# Set umask
sudo cp /lib/systemd/system/php7.4-fpm.service /etc/systemd/system/
serviceconfigpath=/etc/systemd/system/php7.4-fpm.service
serviceconfig="UMask=0002"
if ! grep "${serviceconfig}" "${serviceconfigpath}"
then
  sudo sed -i'.tpm' -E "s/\[Service\]/[Service]\n${serviceconfig}/g" "${serviceconfigpath}"
  sudo rm "${serviceconfigpath}".tmp
fi
sudo systemctl daemon-reload

# Restart PHP-FPM
sudo service php7.4-fpm restart

# Apache configuration
if dpkg --get-selections | grep 'apache2'
then
  sudo apt install -y libapache2-mod-php7.4
  sudo a2enconf php7.4-fpm
  sudo service apache2 restart
fi
