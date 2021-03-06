#!/bin/bash

# Exit script on error
set -e

### Set up variables

# Ask app name if not already set
if [[ -z "${appname}" ]]
then
  read -r -p "Enter the name of your app without hyphens (eg. myawesomeapp): " appname
fi

# Ask for apphow if not already set
if [[ -z "${apphow}" ]]
then
  read -r -p "How do you want to deploy your app?
    - With a domain name & an TSL certificate:  [1]
    - Without a domain name with a local port:  [2]
  Your choice: " apphow
fi

### Domain name case
if [[ ${apphow} == '1' ]]
then

  # Ask email if not already set
  if [[ -z "${email}" ]]
  then
    read -r -p "Enter your email (needed to request TLS certificate): " email
  fi

  # Ask domain name if not already set
  if [[ -z "${appdomain}" ]]
  then
    read -r -p "Enter the domain name on which you want your app to be served (eg. example.com or test.example.com): " appdomain
  fi

  # Activate default conf
  sudo a2ensite 000-default.conf

  # Restart Apache to make changes available
  sudo service apache2 restart

  # Get a new HTTPS certficate
  sudo certbot certonly --webroot -w "/var/www/html" -d "${appdomain}" -m "${email}" -n --agree-tos

  # Disable default conf
  sudo a2dissite 000-default.conf

  # Apache TLS config
  apacheconfig="<VirtualHost *:80>
  # Set up server name
  ServerName ${appdomain}

  # All we need to do here is redirect to HTTPS
  RewriteEngine on
  RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<VirtualHost *:443>
  # Set up server name
  ServerName ${appdomain}

  # Configure separate log files
  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined

  # Configure HTTPS
  SSLEngine on
  SSLCertificateFile /etc/letsencrypt/live/${appdomain}/fullchain.pem
  SSLCertificateKeyFile /etc/letsencrypt/live/${appdomain}/privkey.pem

  # Enable HTTP Strict Transport Security
  Header always set Strict-Transport-Security \"max-age=15552000; includeSubDomains\"
"
fi

### Local port case
if [[ ${apphow} == '2' ]]
then

  # Ask localport if not already set
  if [[ -z "${localport}" ]]
  then
    read -r -p "Define your app running port (eg. 3000): " localport
  fi

  # Allow firewall port
  sudo ufw allow "${localport}"

  # Apache local config
  apacheconfig="Listen ${localport}

<VirtualHost *:${localport}>
  # Set up server name
  ServerName 127.0.0.1

  # Configure separate log files
  ErrorLog /var/log/apache2/${appname}.error.log
  CustomLog /var/log/apache2/${appname}.access.log combined
"
fi

# Ask for apptype if not already set
if [[ -z "${apptype}" ]]
then
  read -r -p "Which type of app do you want to deploy?
    - Proxy to an existing app: [1]
    - HTML/JS/ReactJS/Angular:  [2]
    - NodeJS/NestJS:            [3]
    - PHP/Symfony:              [4]
    - PHP/Nextcloud:            [5]
  Your choice: " apptype
fi

### Proxy case
if [[ "${apptype}" == '1' || "${apptype}" == '3' ]]
then

  # Ask proxyport if not already set
  if [[ -z "${proxyport}" ]]
  then
    read -r -p "Enter the local port to proxy your requests to (eg. 3100): " proxyport
  fi

  # Apache proxy config
  apacheconfig+="
  # Proxy all requests
  ProxyPass / http://127.0.0.1:${proxyport}/
"

  # Ask nextcloudproxy
  if [[ -z "${nextcloudproxy}" ]]
  then
    read -r -p "Are you proxying to a Nextcloud app? [N/y]: " nextcloudproxy
    nextcloudproxy=${nextcloudproxy:-n}
    nextcloudproxy=$(echo "${nextcloudproxy}" | awk '{print tolower($0)}')

    if [[ "${nextcloudproxy}" == 'y' ]]
    then
      apacheconfig+="
  # Well known config
  RewriteEngine On
  RewriteRule ^/\.well-known/carddav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
  RewriteRule ^/\.well-known/caldav https://%{SERVER_NAME}/remote.php/dav/ [R=301,L]
"
    fi
  fi

fi

# Serving case
if [[ "${apptype}" == '2' || "${apptype}" == '4' || "${apptype}" == '5' ]]
  then
  # Create the app directory
  sudo mkdir -p "/var/www/${appname}"

  # Set ownership to Apache
  sudo chown www-data:www-data "/var/www/${appname}"

  # Set permission
  sudo chmod 775 "/var/www/${appname}"

  # Apache document root config
  apacheconfig+="
  # Set up document root
  DocumentRoot /var/www/${appname}
"
fi

### HTML/JS/React/Angular case
if [[ "${apptype}" == '2' ]]
then
  apacheconfig+="  DirectoryIndex /index.html

  # Set up HTML/JS/React/Angular specific configuration
  <Directory />
      Require all denied
  </Directory>
  <Directory /var/www/${appname}>
      Require all granted
      RewriteEngine on
      RewriteCond %{REQUEST_FILENAME} !-f
      RewriteRule ^ index.html [QSA,L]
  </Directory>
"
fi

### NodeJS/NestJS case
if [[ "${apptype}" == '3' ]]
then
  apacheconfig+="
  # Set up NodeJS/NestJS specific configuration
  <Directory />
      Require all denied
  </Directory>

  # Allow CORS requests
  Header set Access-Control-Allow-Origin '*'
"
fi

### PHP/Symfony case
if [[ "${apptype}" == '4' ]]
then
  apacheconfig+="  DirectoryIndex /index.php

  # Set up PHP/Symfony specific configuration
  <Directory />
      Require all denied
  </Directory>
  <Directory /var/www/${appname}/public>
      Require all granted
      php_admin_value open_basedir '/var/www/${appname}'
      php_admin_value upload_tmp_dir '/var/www/${appname}/tmp'
      FallbackResource /index.php
  </Directory>
  <Directory /var/www/${appname}/public/bundles>
      FallbackResource disabled
  </Directory>
"
fi

### PHP/Nextcloud case
if [[ "${apptype}" == '5' ]]
then
  apacheconfig+="  DirectoryIndex /index.php

  # Set up PHP/Nextcloud specific configuration
  <Directory />
      Require all denied
  </Directory>
  <Directory /var/www/${appname}>
      Require all granted
      AllowOverride All
      Options FollowSymLinks MultiViews
      php_admin_value open_basedir '/var/www/${appname}'
      php_admin_value upload_tmp_dir '/var/www/${appname}/tmp'
  </Directory>
  <IfModule mod_dav.c>
    Dav off
  </IfModule>
"
fi

### Set up Apache config
apacheconfig+="</VirtualHost>"
echo "${apacheconfig}" | sudo tee "/etc/apache2/sites-available/${appname}.conf" > /dev/null

# Enable Apache config
sudo a2ensite "${appname}".conf

# Restart Apache to make changes available
sudo service apache2 restart

### Set up SSH reverse tunnel

if [[ "${apphow}" == '2' && -n "${localport}" ]]
then

  read -r -p "Do you want to set up an SSH reverse tunnel to access this app from outside? [N/y]: " sshreversetunnel
  sshreversetunnel=${sshreversetunnel:-n}
  sshreversetunnel=$(echo "${sshreversetunnel}" | awk '{print tolower($0)}')

  if [[ "${sshreversetunnel}" == 'y' ]]
  then

    read -r -p "Enter your SSH login username: " sshreverseuser
    read -r -p "Enter your SSH login host: " sshreversehost
    read -r -p "Enter your SSH login port: " sshreverseport
    read -r -p "Enter the port on the remote machine that will be used to access this app: " sshreverseremoteport

    autosshconfig="[Unit]
Description=AutoSSH tunnel service for ${appname} on port ${localport}
After=network-online.target

[Service]
Restart=always
RestartSec=30s
Environment=\"AUTOSSH_GATETIME=0\"
ExecStart=/usr/bin/autossh -NC -M 0 -o \"ExitOnForwardFailure yes\" -o \"ServerAliveInterval 30\" -o \"ServerAliveCountMax 3\" -o \"PubkeyAuthentication=yes\" -o \"PasswordAuthentication=no\" -i /home/$(whoami)/.ssh/id_rsa -p ${sshreverseport} -R ${sshreverseremoteport}:127.0.0.1:${localport} ${sshreverseuser}@${sshreversehost}

[Install]
WantedBy=multi-user.target"

    echo "${autosshconfig}" | sudo tee "/etc/systemd/system/autossh-${appname}.service" > /dev/null

    sudo systemctl daemon-reload
    sudo systemctl enable autossh-"${appname}"
    sudo systemctl restart autossh-"${appname}"
  fi

fi

### Set up database

if [[ "${apptype}" == '3' || "${apptype}" == '4' || "${apptype}" == '5' ]]
then

  # Ask database password
  if [[ -z "${mysqlpassword}" ]]
  then
    read -r -p "Enter the database password you want for your app (save it in a safe place): " mysqlpassword
  fi

  # Create database and related user for the app and grant permissions
  sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${appname};
  CREATE USER IF NOT EXISTS ${appname}@localhost IDENTIFIED BY '${mysqlpassword}';
  GRANT ALL ON ${appname}.* TO ${appname}@localhost;"
fi

### Create a new SSH user for the app
if [[ "${apptype}" != '1' ]]
then

  # Create a new user
  if ! id -u "${appname}" > /dev/null
  then
    # Generate a new password
    sshpassword=$(openssl rand -hex 15)

    # Encrypt the password
    sshencryptedpassword=$(echo "${sshpassword}" | openssl passwd -crypt -stdin)

    # Create the user and set the default shell
    sudo useradd -m -p "${sshencryptedpassword}" -s /bin/bash "${appname}"
  fi

  # Give Apache group to the user (so that Apache can still access his files)
  sudo usermod -g www-data "${appname}"

  # Give ownership to the user
  sudo chown "${appname}:www-data" "/var/www/${appname}"

  # Create SSH folder in the user home
  sudo mkdir -p "/home/${appname}/.ssh"

  # Copy the authorized_keys file to enable passwordless SSH connections
  sudo cp ~/.ssh/authorized_keys "/home/${appname}/.ssh/authorized_keys"

  # Give ownership to the user
  sudo chown -R "${appname}:${appname}" "/home/${appname}/.ssh"

  ### Create a chroot jail for this user

  # Create the jail
  sudo username="${appname}" use_basic_commands=n bash -c "$(cat "${PWD}"/scripts/jail.sh)"

  # Mount the app folder into the jail
  sudo mount --bind "/var/www/${appname}" "/jails/${appname}/home/${appname}"

  # Make the mount permanent
  mountconfig="/var/www/${appname} /jails/${appname}/home/${appname} none rw,bind 0 0"
  if ! grep "${mountconfig}" /etc/fstab > /dev/null
  then
    echo "${mountconfig}" | sudo tee -a /etc/fstab > /dev/null
  fi
fi
