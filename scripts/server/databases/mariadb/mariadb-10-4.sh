#!/bin/bash

### MariaDB 10.4

# Add MariaDB official repository
test -f /etc/apt/sources.list.d/mariadb.list || curl -sS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo -E bash -s -- --mariadb-server-version=mariadb-10.4

# Install
sudo apt install -y mariadb-server-10.4

# Show MariaDB version
sudo mysql -e "SELECT VERSION();"
