#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function GenerateTlsCertificateWithCertbot () {
  applicationName="${1}"
  domainName="${2}"
  email="${3}"
  sudo certbot certonly --webroot --webroot-path "/var/www/${applicationName}" --domain "${domainName}" --email "${email}" -n --agree-tos
}

function ConfigureRequestLimits () {
  fileContent="limit_req_zone \$binary_remote_addr zone=ip:10m rate=15r/s;
limit_req_status 429;"
  filePath=/etc/nginx/conf.d/limit_req.conf
  SetFileContent "${fileContent}" "${filePath}"
  RestartService 'nginx'
}

function GenerateTlsCertificate () {
  applicationName="${1}"
  domainName="${2}"
  email="${3}"
  webRootPath=/var/www/"${applicationName}"
  applicationDirectoryConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"
  applicationConfigurationPath=/etc/nginx/sites-available/"${applicationName}".conf
  applicationEnabledConfigurationPath=/etc/nginx/sites-enabled/"${applicationName}".conf
  applicationConfiguration="include ${applicationDirectoryConfigurationPath}/*.conf;"
  SetFileContent "${applicationConfiguration}" "${applicationConfigurationPath}"
  CreateDirectoryIfNotExisting "${applicationDirectoryConfigurationPath}"
  domainDirectoryConfigurationPath="${applicationDirectoryConfigurationPath}"/"${domainName}"
  domainConfigurationPath="${applicationDirectoryConfigurationPath}"/"${domainName}".conf
  domainConfiguration="include ${domainDirectoryConfigurationPath}/*.conf;"
  SetFileContent "${domainConfiguration}" "${domainConfigurationPath}"
  CreateDirectoryIfNotExisting "${domainDirectoryConfigurationPath}"
  httpConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"/"${domainName}"/http.conf
  httpConfiguration="server {
  listen 80;
  listen [::]:80;
  server_name ${domainName};

  root ${webRootPath};

  error_log  /var/log/nginx/${applicationName}.error.log error;
  access_log /var/log/nginx/${applicationName}.access.log;

  location /.well-known/acme-challenge/ {
    limit_req zone=ip burst=20 nodelay;
    try_files \$uri =404;
  }

  location / {
    limit_req zone=ip burst=20 nodelay;
    return 301 https://\$host\$request_uri;
  }
}"
  SetFileContent "${httpConfiguration}" "${httpConfigurationPath}"
  CreateDirectoryIfNotExisting "${webRootPath}"
  SetDirectoryOwnershipRecursively "${webRootPath}" "www-data"
  SetDefaultDirectoryPermissions "${webRootPath}"
  CreateFileSymbolicLinkIfNotExisting "${applicationEnabledConfigurationPath}" "${applicationConfigurationPath}"
  ConfigureRequestLimits
  RestartService 'nginx'
  GenerateTlsCertificateWithCertbot "${applicationName}" "${domainName}" "${email}"
}
