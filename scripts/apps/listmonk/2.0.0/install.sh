#!/bin/bash

set -e

#### Inputs
databaseName=$1
if [[ -z "${databaseName}" ]]
then
  read -r -p "Choose your database name: " databaseName
fi

databaseUser=$2
if [[ -z "${databaseUsername}" ]]
then
  read -r -p "Choose your database username: " databaseUsername
fi

databasePassword=$3
if [[ -z "${databasePassword}" ]]
then
  read -r -p "Choose your database password: " databasePassword
fi

listmonkDomain=$4
if [[ -z "${listmonkDomain}" ]]
then
  read -r -p "Choose your Listmonk domain: " listmonkDomain
fi

adminUsername=$5
if [[ -z "${adminUsername}" ]]
then
  read -r -p "Choose your Listmonk admin username: " adminUsername
fi

adminPassword=$6
if [[ -z "${adminPassword}" ]]
then
  read -r -p "Choose your Listmonk admin password: " adminPassword
fi

email=$7
if [[ -z "${email}" ]]
then
  read -r -p "Enter your email (needed to request TLS certificate): " email
fi

#### Constants
listmonkPort="9000"
listmonkName="listmonk"

#### Install dependencies
bash ~/server-setup/scripts/server/postgresql/14/install.sh

databasesList=$(sudo -u postgres psql -l)
usersList=$(sudo -u postgres psql -c "\du+")
echo "${databasesList}" | grep "${databaseName}" || sudo -u postgres psql -c "CREATE DATABASE '${databaseName}';"
echo "${usersList}"  | grep "${databaseUsername}" || sudo -u postgres psql -d "${databaseName}" -c "CREATE USER ${databaseUsername};"
sudo -u postgres psql -d "${databaseName}" -c "ALTER USER \"${databaseUsername}\" with encrypted password '${databasePassword}';"
sudo -u postgres psql -d "${databaseName}" -c "GRANT ALL PRIVILEGES ON DATABASE \"${databaseName}\" TO \"${databaseUsername}\";"

#### Install app
test -f /tmp/listmonk_2.0.0_linux_amd64.tar.gz || wget https://github.com/knadh/listmonk/releases/download/v2.0.0/listmonk_2.0.0_linux_amd64.tar.gz -P /tmp
test -d || /opt/listmonk tar -zxvf /tmp/listmonk_2.0.0_linux_amd64.tar.gz -C /opt/listmonk
rm /tmp/listmonk_2.0.0_linux_amd64.tar.gz

#### Configure app
listmonkConfig="
[app]
address = \"localhost:${listmonkPort}\"
admin_username = \"${adminUsername}\"
admin_password = \"${adminPassword}\"

[db]
host = \"localhost\"
port = 5432
user = \"${databaseUser}\"
password = \"${databasePassword}\"
database = \"${databaseName}\"
ssl_mode = \"disable\"
max_open = 25
max_idle = 25
max_lifetime = \"300s\"
"
echo "${listmonkConfig}" | sudo tee /opt/listmonk/config.toml > /dev/null
/opt/listmonk/listmonk --install --config /opt/listmonk/config.toml

bash ~/server-setup/scripts/management/nginx-certbot/get-tls-certificate.sh "${listmonkName}" "${email}" "${listmonkDomain}"
bash ~/server-setup/scripts/management/nginx-certbot/set-up-domain-name-app.sh "${listmonkName}" "${email}" "1" "${listmonkPort}"

serviceConfig="[Unit]
Description=Autostart tunnel service for ${listmonkName}
After=network-online.target

[Service]
Restart=always
RestartSec=30s
ExecStart=//opt/listmonk/listmonk

[Install]
WantedBy=multi-user.target
"
echo "${serviceConfig}" | sudo tee "/etc/systemd/system/${listmonkName}.service" > /dev/null

sudo systemctl daemon-reload
sudo systemctl enable "${listmonkName}"
sudo systemctl restart "${listmonkName}"
