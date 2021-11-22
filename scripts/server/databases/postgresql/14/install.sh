#!/bin/bash

set -e

test -f /etc/apt/sources.list.d/pgdg.list || (sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && sudo apt-key adv --fetch-keys 'https://www.postgresql.org/media/keys/ACCC4CF8.asc' && sudo apt update)
dpkg -s postgresql-14 > /dev/null || (sudo apt install -y postgresql-14)