#!/bin/bash

### PHP 7.4

# Exit script on error
set -e

# Add PHP official repository
sudo add-apt-repository -y ppa:ondrej/php

# Install PHP
sudo apt install -y php7.4 php7.4-fpm libapache2-mod-php7.4

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

# Restart Apache
sudo service apache2 restart
