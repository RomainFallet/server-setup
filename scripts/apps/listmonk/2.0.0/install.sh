#!/bin/bash

set -e

#### Inputs
appName=$1
if [[ -z "${appName}" ]]
then
  read -r -p "Choose your app name: " appName
fi

appPort=$2
if [[ -z "${appPort}" ]]
then
  read -r -p "Choose your app port: " appPort
fi

appDomain=$3
if [[ -z "${appDomain}" ]]
then
  read -r -p "Choose your app domain: " appDomain
fi

adminUsername=$4
if [[ -z "${adminUsername}" ]]
then
  read -r -p "Choose your app admin username: " adminUsername
fi

adminPassword=$5
if [[ -z "${adminPassword}" ]]
then
  read -r -p "Choose your app admin password: " adminPassword
fi

databasePassword=$6
if [[ -z "${databasePassword}" ]]
then
  read -r -p "Choose your database password: " databasePassword
fi

email=$6
if [[ -z "${email}" ]]
then
  read -r -p "Enter your email (needed to request TLS certificate): " email
fi

#### Install dependencies
bash ~/server-setup/scripts/server/databases/postgresql/14/install.sh

databasesList=$(sudo -u postgres psql -l)
usersList=$(sudo -u postgres psql -c "\du+")
echo "${databasesList}" | grep "${appName}" || sudo -u postgres psql -c "CREATE DATABASE ${appName};"
echo "${usersList}"  | grep "${appName}" || sudo -u postgres psql -d "${appName}" -c "CREATE USER ${appName};"
sudo -u postgres psql -d "${appName}" -c "ALTER USER \"${appName}\" with encrypted password '${databasePassword}';"
sudo -u postgres psql -d "${appName}" -c "GRANT ALL PRIVILEGES ON DATABASE \"${appName}\" TO \"${appName}\";"

#### Install app
test -f /tmp/listmonk_2.0.0_linux_amd64.tar.gz || wget https://github.com/knadh/listmonk/releases/download/v2.0.0/listmonk_2.0.0_linux_amd64.tar.gz -P /tmp
test -d || /opt/listmonk tar -zxvf /tmp/listmonk_2.0.0_linux_amd64.tar.gz -C /opt/listmonk
rm /tmp/listmonk_2.0.0_linux_amd64.tar.gz

#### Configure app
listmonkConfig="
[app]
address = \"localhost:${appPort}\"
admin_username = \"${adminUsername}\"
admin_password = \"${adminPassword}\"

[db]
host = \"localhost\"
port = 5432
user = \"${appName}\"
password = \"${databasePassword}\"
database = \"${appName}\"
ssl_mode = \"disable\"
max_open = 25
max_idle = 25
max_lifetime = \"300s\"
"
echo "${listmonkConfig}" | sudo tee /opt/listmonk/config.toml > /dev/null
/opt/listmonk/listmonk --install --config /opt/listmonk/config.toml

bash ~/server-setup/scripts/management/nginx-certbot/get-tls-certificate.sh "${appName}" "${email}" "${appDomain}"
bash ~/server-setup/scripts/management/nginx-certbot/set-up-domain-name-app.sh "${appName}" "${email}" "1" "${appPort}"

serviceConfig="[Unit]
Description=Autostart tunnel service for ${appName}
After=network-online.target

[Service]
Restart=always
RestartSec=30s
ExecStart=//opt/listmonk/listmonk

[Install]
WantedBy=multi-user.target
"
echo "${serviceConfig}" | sudo tee "/etc/systemd/system/${appName}.service" > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable "${appName}"
sudo systemctl restart "${appName}"
