#!/bin/bash

set -e

### MariaDB 10.4

# Add repository key
if ! sudo apt-key list | grep 'MariaDB'
then
  sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
fi

# Add repository
if ! grep 'MariaDB/repo/10.4' /etc/apt/sources.list
then
  sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mariadb.mirrors.ovh.net/MariaDB/repo/10.4/ubuntu focal main'
  sudo apt update
fi

# Install deps
sudo apt install -y galera-4 libcgi-fast-perl libcgi-pm-perl libdbd-mariadb-perl libdbi-perl libencode-locale-perl libfcgi-perl libhtml-parser-perl libhtml-tagset-perl libhtml-template-perl libhttp-date-perl libhttp-message-perl libio-html-perl liblwp-mediatypes-perl libmariadb3 libmysqlclient21 libterm-readkey-perl libtimedate-perl liburi-perl mariadb-common mysql-common python3-xkit socat ubuntu-drivers-common

# Install
sudo apt install -y mariadb-server-10.4

# Stop service
sudo service mariadb stop
sudo rm -f /lib/systemd/system/mariadb.service
sudo systemctl daemon-reload

# Create config directory
if ! test -d /etc/mariadb
then
  sudo mkdir /etc/mariadb
fi
if ! test -d /etc/mariadb/10.4
then
  sudo mv /etc/mysql /etc/mariadb/10.4
  sudo rm -f /etc/mariadb/10.4/my.cnf
  echo "[client-server]
  socket=/var/run/mariadb/10.4/mariadb.sock
  port=3308
  [mysqld]
  user=mysql
  datadir=/var/lib/mariadb/10.4
  log_error=/var/log/mariadb/10.4/error.log" | sudo tee /etc/mariadb/10.4/my.cnf > /dev/null
fi

# Create log directory
if ! test -d /var/log/mariadb/10.4
then
  sudo mkdir -p /var/log/mariadb/10.4
fi

# Create data directory
if ! test -d /var/lib/mariadb
then
  sudo mkdir /var/lib/mariadb
fi
if ! test -d /var/lib/mariadb/10.4
then
  sudo mv /var/lib/mysql /var/lib/mariadb/10.4
fi

# Create socket directory
if ! test -d /var/run/mariadb
then
  sudo mkdir /var/run/mariadb
fi
if ! test -d /var/run/mariadb/10.4/
then
  sudo mv /var/run/mysqld /var/run/mariadb/10.4/
fi

# Create bin directory
if ! test -d /usr/local/mariadb/10.4/bin
then
  sudo mkdir -p /usr/local/mariadb/10.4/bin
  sudo mv /usr/bin/mariadb* /usr/local/mariadb/10.4/bin/
fi

# Create sbin directory
if ! test -d /usr/local/mariadb/10.4/sbin
then
  sudo mkdir -p /usr/local/mariadb/10.4/sbin
  sudo mv /usr/sbin/mariadb* /usr/local/mariadb/10.4/sbin/
fi

# Clean up installation
sudo rm -rf /usr/bin/mysql* /usr/sbin/mysql* /usr/bin/maridb* /usr/sbin/maridb* /var/lib/mysql /etc/mysql /var/run/mysqld /var/log/mysql /usr/share/mysql
sudo apt remove --purge -y mariadb-server-10.4

# Create service file
if ! test -f /lib/systemd/system/mariadb-10.4.service
then
  echo "[Unit]
  Description=Mariadb 10.4

  Wants=network.target
  After=syslog.target network-online.target

  [Service]
  Type=simple
  ExecStart=/usr/local/mariadb/10.4/sbin/mariadbd --defaults-file=/etc/mariadb/10.4/my.cnf
  Restart=on-failure
  RestartSec=10
  KillMode=mixed

  [Install]
  WantedBy=multi-user.target" | sudo tee /lib/systemd/system/mariadb-10.4.service > /dev/null
  sudo systemctl daemon-reload
fi

# Enable service on system startup
sudo systemctl enable mariadb-10.4
sudo service mariadb-10.4 start
