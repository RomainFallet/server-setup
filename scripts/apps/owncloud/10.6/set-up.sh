#!/bin/bash

# Exit script on error
set -e

### Set up

# Ask appname if not already set
if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

# Ask adminusername if not already set
if [[ -z "${adminusername}" ]]
then
  read -r -p "Enter the username of the admin account to create: " adminusername
fi

# Ask adminpassword if not already set
if [[ -z "${adminpassword}" ]]
then
  read -r -p "Enter the password of the admin account to create: " adminpassword
fi

# Install deps
sudo apt install -y jq inetutils-ping smbclient

# Download owncloud
wget https://download.owncloud.org/community/owncloud-complete-20201216.tar.bz2 -O /tmp/owncloud-10.6.tar.bz2

# Install files
mkdir -p /tmp/owncloud-10.6
tar -xvjf /tmp/owncloud-10.6.tar.bz2 --directory /tmp/owncloud-10.6
sudo mv /tmp/owncloud-10.6/owncloud/* /var/www/"${appname}"/

# Set permissions
sudo chown -R www-data:www-data /var/www/"${appname}"

# Clean up install files
sudo rm -rf /tmp/owncloud-10.6 /tmp/owncloud-10.6.tar.bz2

# Create database
# shellcheck source=./../../../management/mariadb/10.5/create-database.sh
source ~/server-setup/scripts/management/mariadb/10.5/create-database.sh

# Create database user
# shellcheck source=./../../../management/mariadb/10.5/create-user.sh
source ~/server-setup/scripts/management/mariadb/10.5/create-user.sh

# Create owncloud admin account
sudo -u www-data /usr/bin/php /var/www/"${appname}"/occ maintenance:install --database-connection-string="mysql://${dbusername}:${dbpassword}@localhost:3307/${dbname}" --admin-user "${adminusername}" --admin-pass "${adminpassword}"

# Config cron jobs
sudo -u www-data /usr/bin/php /var/www/"${appname}"/occ background:cron
cronconfig="*/15  *  *  *  * /var/www/${appname}/occ system:cron"
cronpath=/var/spool/cron/crontabs/www-data
if [[ $(< "${cronpath}") != *"${cronconfig}"* ]]
then
  echo "${cronconfig}" | sudo tee -a "${cronpath}" > /dev/null
fi
sudo chown www-data.crontab /var/spool/cron/crontabs/www-data
sudo chmod 0600 /var/spool/cron/crontabs/www-data

# Configure cache
sudo -u www-data /usr/bin/php /var/www/"${appname}"/occ config:system:set memcache.local --value '\OC\Memcache\APCu'
sudo -u www-data /usr/bin/php /var/www/"${appname}"/occ config:system:set memcache.locking --value '\OC\Memcache\Redis'
sudo -u www-data /usr/bin/php /var/www/"${appname}"/occ config:system:set redis --value '{"host": "127.0.0.1", "port": "6379"}' --type json

# Configure log rotation
echo "/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}" | sudo tee /etc/logrotate.d/owncloud > /dev/null
