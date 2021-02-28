#!/bin/bash

# Exit script on error
set -e

### Create database

# Ask dbname if not already set
if [[ -z "${dbname}" ]]
then
read -r -p "Enter your database name: " dbname
fi

# Create database
sudo /usr/local/mariadb/10.5/bin/mariadb --defaults-file=/etc/mariadb/10.5/my.cnf -e "CREATE DATABASE IF NOT EXISTS ${dbname};"
