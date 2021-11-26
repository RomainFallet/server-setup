#!/bin/bash

# Exit script on error
set -e

### NodeJS 16

# Add PostgreSQL official repository and update packages list
test -f /etc/apt/sources.list.d/pgdg.list || (sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && sudo apt-key adv --fetch-keys 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' && sudo apt update)

# Install PostgreSQL
dpkg -s postgresql-14 > /dev/null || (sudo apt install -y postgresql-14)
