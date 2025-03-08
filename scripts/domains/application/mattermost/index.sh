#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mattermost/utilities.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/databases/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/web-server/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SetupMattermost () {
  mattermostApplicationName='mattermost'
  mattermostPath=/var/opt/mattermost
  mattermostConfigurationFilePath="${mattermostPath}"/config/config.json
  mattermostDownloadPath=/tmp/mattermost.tar.gz
  mattermostDatabaseName="${mattermostApplicationName}db"
  mattermostDataDirectory=/var/lib/mattermost
  mattermortFilesDirectory="${mattermostDataDirectory}"/files
  mattermostPluginsDirectory="${mattermostDataDirectory}"/plugins
  mattermostClientPluginsDirectory="${mattermostDataDirectory}"/client/plugins
  mattermostSocketPath=/var/tmp/mattermost_local.socket
  AskIfNotSet mattermostDatabasePassword "Enter your Mattermost database password"
  AskIfNotSet mattermostDomainName "Enter your Mattermost domain name"
  AskIfNotSet mattermostInternalPort "Enter your Mattermost internal port"
  AskIfNotSet mattermostSmtpHostName "Enter your Mattermost SMTP hostname"
  AskIfNotSet mattermostSmtpUserName "Enter your Mattermost SMTP username" "${mattermostApplicationName}@${mattermostSmtpHostName:?}"
  AskIfNotSet mattermostSmtpPassword "Enter your Mattermost SMTP password"
  AskIfNotSet mattermostSmtpPort "Enter your Mattermost SMTP port" '465'
  AskIfNotSet mattermostAdministratorUserName "Enter your Mattermost administrator username"
  AskIfNotSet mattermostAdministratorEmail "Enter your Mattermost administrator email"
  AskIfNotSet mattermostAdministratorPassword "Enter your Mattermost administrator password"
  AskIfNotSet mattermostDefaultTeamIdentifier "Enter your Mattermost default team identifier"
  AskIfNotSet mattermostDefaultTeamName "Enter your Mattermost default team name"
  CreateUserIfNotExisting "${mattermostApplicationName}"
  CreatePostgreSqlUserIfNotExisting "${mattermostApplicationName}" "${mattermostDatabasePassword:?}"
  CreatePostgreSqlDatabaseIfNotExisting "${mattermostDatabaseName}"
  GrantAllPrivilegesOnPostgreSqlDatabase "${mattermostDatabaseName}" "${mattermostApplicationName}"
  DownloadMattermostIfOutdated "${mattermostDownloadPath}" "${mattermostPath}" "${mattermostApplicationName}"
  CreateDirectoryIfNotExisting "${mattermortFilesDirectory}"
  CreateDirectoryIfNotExisting "${mattermostPluginsDirectory}"
  CreateDirectoryIfNotExisting "${mattermostClientPluginsDirectory}"
  SetDirectoryOwnershipRecursively "${mattermostDataDirectory}" "${mattermostApplicationName}"
  SetMattermostConfigurationFileContent "${mattermostConfigurationFilePath}" "${mattermostApplicationName}" "${mattermostDatabasePassword}" "${mattermostDatabaseName}"
  CreateStartupService "${mattermostApplicationName}" "/var/opt/mattermost/bin/mattermost" "${mattermostApplicationName}" "/var/opt/mattermost/" '' 'postgresql.service'
  SetDirectoryOwnershipRecursively "${mattermostPath}" "${mattermostApplicationName}"
  RestartService "${mattermostApplicationName}"
  WaitForMattermostSocketToBeCreated "${mattermostSocketPath}"
  SetFileOwnership "${mattermostSocketPath}" "${mattermostApplicationName}"
  ConfigureMattermost "${mattermostApplicationName}" "${mattermortFilesDirectory}" "${mattermostPluginsDirectory}" "${mattermostClientPluginsDirectory}"
  CreateOrUpdateMattermostAdministratorAccount "${mattermostAdministratorUserName:?}" "${mattermostAdministratorEmail:?}" "${mattermostAdministratorPassword:?}" "${mattermostApplicationName}"
  CreateOrUpdateMattermostDefaultTeam "${mattermostDefaultTeamIdentifier:?}" "${mattermostDefaultTeamName:?}" "${mattermostAdministratorUserName:?}" "${mattermostApplicationName}"
  ManageMattermostPlugins "${mattermostApplicationName}"
}

function SetupMattermostWebServer () {
  mattermostApplicationName='mattermost'
  AskIfNotSet mattermostDomainName "Enter your Mattermost domain name"
  AskIfNotSet mattermostInternalPort "Enter your Mattermost internal port"
  CreateProxyDomainName "${mattermostApplicationName}" "${mattermostDomainName:?}" "${mattermostInternalPort:?}" 'default'
  nginxConfigurationPath=/etc/nginx/sites-configuration/"${mattermostApplicationName}"/"${mattermostDomainName:?}"/https.conf
  nginxConfiguration="upstream backend {
   server 127.0.0.1:${mattermostInternalPort:?};
   keepalive 32;
}

  server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${mattermostDomainName:?};

  root /var/www/${mattermostApplicationName};

  http2_push_preload on;

  location ~ /api/v[0-9]+/(users/)?websocket$ {
    client_max_body_size 50M;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \"upgrade\";
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Frame-Options SAMEORIGIN;
    proxy_buffers 256 16k;
    proxy_buffer_size 16k;
    client_body_timeout 60;
    send_timeout 300;
    lingering_timeout 5;
    proxy_connect_timeout 90;
    proxy_send_timeout 300;
    proxy_read_timeout 90s;
    proxy_http_version 1.1;
    proxy_pass http://backend;
  }

  location / {
    limit_req zone=ip burst=100 nodelay;
    client_max_body_size 50M;
    proxy_set_header Connection \"\";
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Frame-Options SAMEORIGIN;
    proxy_buffers 256 16k;
    proxy_buffer_size 16k;
    proxy_read_timeout 600s;
    proxy_http_version 1.1;
    proxy_pass http://backend;
  }

  error_log  /var/log/nginx/${mattermostApplicationName}.error.log error;
  access_log /var/log/nginx/${mattermostApplicationName}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${mattermostDomainName:?}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${mattermostDomainName:?}/privkey.pem;

  add_header Strict-Transport-Security \"max-age=15552000; preload;\";
  add_header Expect-CT \"max-age=86400, enforce\";
  add_header X-Frame-Options \"SAMEORIGIN\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Cache-Control \"no-store\";
  add_header Permissions-Policy \"fullscreen=(); microphone=(); geolocation=(); camera=(); midi=(); sync-xhr=(); magnetometer=(); gyroscope=(); payment=();\";
  include /etc/nginx/sites-configuration/${mattermostApplicationName}/${mattermostDomainName:?}/content-security-policy.conf;
}"
  SetFileContent "${nginxConfiguration}" "${nginxConfigurationPath}"
  mattermostContentSecurityPolicyConfigurationPath=/etc/nginx/sites-configuration/"${mattermostApplicationName}"/"${mattermostDomainName}"/content-security-policy.conf
  mattermostContentSecurityPolicyConfiguration="add_header Content-Security-Policy \"default-src 'self' 'unsafe-inline' data: blob:;\";"
  SetFileContent "${mattermostContentSecurityPolicyConfiguration}" "${mattermostContentSecurityPolicyConfigurationPath}"
  RestartService 'nginx'
}
