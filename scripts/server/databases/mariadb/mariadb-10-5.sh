#!/bin/bash

set -e

### MariaDB 10.5
if ! sudo apt-key list | grep 'MariaDB'
then
  sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
fi
if ! grep 'MariaDB/repo/10.5' /etc/apt/sources.list
then
  sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://mariadb.mirrors.ovh.net/MariaDB/repo/10.5/ubuntu focal main'
  sudo apt update
fi

sudo apt install -y mariadb-server-10.5
sudo service mariadb stop
sudo rm -f /lib/systemd/system/mariadb.service
sudo systemctl daemon-reload

if ! test -d /etc/mariadb
then
  sudo mkdir /etc/mariadb
fi
if ! test -d /etc/mariadb/10.5
then
  sudo mv /etc/mysql /etc/mariadb/10.5
  sudo rm /etc/mariadb/10.5/my.cnf
  echo "[client-server]
  socket=/tmp/mariadb-10.5.sock
  port=3307
  [mysqld]
  user=mysql
  datadir=/var/lib/mariadb/10.5
  log_error=/var/log/mysql/mariadb.err" | sudo tee /etc/mariadb/10.5/my.cnf > /dev/null
fi
if ! test -d /var/log/mariadb/10.5
then
  sudo mkdir -p /var/log/mariadb/10.5
fi
if ! test -d /var/lib/mariadb
then
  sudo mkdir /var/lib/mariadb
fi
if ! test -d /var/lib/mariadb/10.5
then
  sudo mv /var/lib/mysql /var/lib/mariadb/10.5
fi
if ! test -d /var/run/mariadb
then
  sudo mkdir /var/run/mariadb
fi
if ! test -d /var/run/mariadb/10.5/
then
  sudo mv /var/run/mysqld /var/run/mariadb/10.5/
fi
if ! test -d /usr/local/mariadb/10.5/bin
then
  sudo mkdir -p /usr/local/mariadb/10.5/bin
  sudo mv /usr/bin/mariadb* /usr/local/mariadb/10.5/bin/
fi
if ! test -d /usr/local/mariadb/10.5/sbin
then
  sudo mkdir -p /usr/local/mariadb/10.5/sbin
  sudo mv /usr/sbin/mariadb* /usr/local/mariadb/10.5/sbin/
fi

sudo apt autoremove --purge -y mariadb-server-10.5
sudo rm -rf /usr/bin/mysql* /usr/sbin/mysql*

if ! test -f /lib/systemd/system/mariadb-10.5.service
then
  echo "[Unit]
  Description=Mariadb 10.5

  Wants=network.target
  After=syslog.target network-online.target

  [Service]
  Type=simple
  ExecStart=/usr/local/mariadb/10.5/sbin/mariadbd --defaults-file=/etc/mariadb/10.5/my.cnf
  Restart=on-failure
  RestartSec=10
  KillMode=mixed

  [Install]
  WantedBy=multi-user.target" | sudo tee /lib/systemd/system/mariadb-10.5.service > /dev/null
fi
sudo systemctl daemon-reload
sudo service mariadb-10.5 start
