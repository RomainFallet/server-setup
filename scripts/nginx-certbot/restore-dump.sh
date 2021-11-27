#!/bin/bash

# Exit script on error
set -e

### Restore dump of Nginx and Letsencrypt

# Ask source path if not already set
sourcePath=$1
if [[ -z "${sourcePath}" ]]
then
  read -r -p "Enter the source path of your Nginx & Letsencrypt dump folder: " sourcePath
fi

# Restore dump
sudo rm -rf /var/www /etc/nginx /etc/letsencrypt
sudo cp --archive "${sourcePath}"/www /var/www
sudo cp --archive "${sourcePath}"/nginx /etc/nginx
sudo cp --archive "${sourcePath}"/letsencrypt /etc/letsencrypt
sudo chown -R www-data:www-data /var/www
sudo chown -R root:root /etc/nginx /etc/letsencrypt
