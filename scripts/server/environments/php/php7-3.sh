#!/bin/bash

### PHP 7.3

# Exit script on error
set -e

# Add PHP official repository
sudo add-apt-repository -y ppa:ondrej/php

# Install PHP
sudo apt install -y php7.3 php7.3-fpm libapache2-mod-php7.3

# Install Redis for PHP cache
sudo apt install -y redis-server

# Install extensions
sudo apt install -y php7.3-mbstring php7.3-mysql php7.3-xml php7.3-curl php7.3-zip php7.3-intl php7.3-gd php7.3-bcmath php7.3-gmp php-redis php-imagick

# Make a backup of the config file
phpinipath=/etc/php/7.3/fpm/php.ini
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

# Restart PHP-FPM
sudo service php7.4-fpm restart
