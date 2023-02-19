#!/bin/bash

function InstallFail2BanIfNotExisting () {
  if ! dpkg --status fail2ban &> /dev/null; then
    sudo apt install -y fail2ban
  fi
}

function CreateFail2BanConfiguration () {
  configuration="[DEFAULT]
findtime = 3600
bantime = 86400

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3"
  echo "${configuration}" | sudo tee /etc/fail2ban/jail.local > /dev/null
}

function RestartFail2Ban () {
  sudo service fail2ban restart
}

export -f InstallFail2BanIfNotExisting
export -f CreateDefaultConfiguration
export -f RestartFail2Ban
