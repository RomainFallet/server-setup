#!/bin/bash

# Exit script on error
set -e

### Create database user

# Ask dbname if not already set
if [[ -z "${dbname}" ]]
then
read -r -p "Enter your database name: " dbname
fi

# Ask dbusername if not already set
if [[ -z "${dbusername}" ]]
then
read -r -p "Enter your database user name: " dbusername
fi

# Ask dbusername if not already set
if [[ -z "${dbpassword}" ]]
then
read -r -p "Enter your database password: " dbpassword
fi

# Create user
sudo /usr/local/mariadb/10.5/bin/mariadb --defaults-file=/etc/mariadb/10.5/my.cnf -e "CREATE USER IF NOT EXISTS ${dbusername}@localhost IDENTIFIED BY '${dbpassword}';
GRANT ALL ON ${dbname}.* TO ${dbusername}@localhost;"
