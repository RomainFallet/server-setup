#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/web-server/utilities.sh"

function CreateProxyDomainName () {
  applicationName="${1}"
  domainName="${2}"
  internalPort="${3}"
  letsencryptEmail="${4}"
  cspBehavior="${5}"
  GenerateTlsCertificate "${applicationName}" "${domainName}" "${letsencryptEmail}"
  httpsConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"/"${domainName}"/https.conf
  httpsConfiguration="server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${domainName};

  root /var/www/${applicationName};

  location / {
    limit_req zone=ip burst=100 nodelay;
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_pass_request_headers on;
    proxy_pass http://127.0.0.1:${internalPort};
  }

  error_log  /var/log/nginx/${applicationName}.error.log error;
  access_log /var/log/nginx/${applicationName}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${domainName}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${domainName}/privkey.pem;

  add_header Strict-Transport-Security \"max-age=15552000; preload;\";
  add_header Expect-CT \"max-age=86400, enforce\";
  add_header X-Frame-Options \"deny\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Cache-Control \"no-store\";
  add_header Permissions-Policy \"fullscreen=(); microphone=(); geolocation=(); camera=(); midi=(); sync-xhr=(); magnetometer=(); gyroscope=(); payment=();\";
  include /etc/nginx/sites-configuration/${applicationName}/${domainName}/content-security-policy.conf;
}"
  SetFileContent "${httpsConfiguration}" "${httpsConfigurationPath}"
  ConfigureContentSecurityPolicy "${applicationName}" "${domainName}" "${cspBehavior}"
  RestartService 'nginx'
}

function CreateStaticDomainName () {
  applicationName="${1}"
  domainName="${2}"
  letsencryptEmail="${3}"
  cspBehavior="${4}"
  GenerateTlsCertificate "${applicationName}" "${domainName}" "${letsencryptEmail}"
  httpsConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"/"${domainName}"/https.conf
  httpsConfiguration="server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${domainName};

  root /var/www/${applicationName};

  location / {
    limit_req zone=ip burst=100 nodelay;
    try_files \$uri \$uri/ =404;
  }

  error_log  /var/log/nginx/${applicationName}.error.log error;
  access_log /var/log/nginx/${applicationName}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${domainName}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${domainName}/privkey.pem;

  add_header Strict-Transport-Security \"max-age=15552000; preload;\";
  add_header Expect-CT \"max-age=86400, enforce\";
  add_header X-Frame-Options \"deny\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Cache-Control \"private, max-age=604800, must-revalidate\";
  add_header Permissions-Policy \"fullscreen=(); microphone=(); geolocation=(); camera=(); midi=(); sync-xhr=(); magnetometer=(); gyroscope=(); payment=();\";
  include /etc/nginx/sites-configuration/${applicationName}/${domainName}/content-security-policy.conf;
}"
  SetFileContent "${httpsConfiguration}" "${httpsConfigurationPath}"
  ConfigureContentSecurityPolicy "${applicationName}" "${domainName}" "${cspBehavior}"
  RestartService 'nginx'
}

function CreateSpaDomainName () {
  applicationName="${1}"
  domainName="${2}"
  letsencryptEmail="${3}"
  cspBehavior="${4}"
  GenerateTlsCertificate "${applicationName}" "${domainName}" "${letsencryptEmail}"
  httpsConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"/"${domainName}"/https.conf
  httpsConfiguration="server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${domainName};

  root /var/www/${applicationName};

  location / {
    limit_req zone=ip burst=100 nodelay;
    try_files \$uri \$uri/ /index.html;
  }

  error_log  /var/log/nginx/${applicationName}.error.log error;
  access_log /var/log/nginx/${applicationName}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${domainName}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${domainName}/privkey.pem;

  add_header Strict-Transport-Security \"max-age=15552000; preload;\";
  add_header Expect-CT \"max-age=86400, enforce\";
  add_header X-Frame-Options \"deny\";
  add_header X-Content-Type-Options \"nosniff\";
  add_header Referrer-Policy \"same-origin\";
  add_header Cache-Control \"private, max-age=604800, must-revalidate\";
  add_header Permissions-Policy \"fullscreen=(); microphone=(); geolocation=(); camera=(); midi=(); sync-xhr=(); magnetometer=(); gyroscope=(); payment=();\";
  include /etc/nginx/sites-configuration/${applicationName}/${domainName}/content-security-policy.conf;
}"
  SetFileContent "${httpsConfiguration}" "${httpsConfigurationPath}"
  ConfigureContentSecurityPolicy "${applicationName}" "${domainName}" "${cspBehavior}"
  RestartService 'nginx'
}

function CreateRedirectionDomainName () {
  applicationName="${1}"
  domainName="${2}"
  redirectionDomainName="${3}"
  letsencryptEmail="${4}"
  GenerateTlsCertificate "${applicationName}" "${domainName}" "${letsencryptEmail}"
  httpsConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"/"${domainName}"/https.conf
  httpsConfiguration="server {
  listen 443      ssl http2;
  listen [::]:443 ssl http2;
  server_name ${domainName};

  root /var/www/${applicationName};

  error_log  /var/log/nginx/${applicationName}.error.log error;
  access_log /var/log/nginx/${applicationName}.access.log;

  ssl_certificate     /etc/letsencrypt/live/${domainName}/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/${domainName}/privkey.pem;

  location / {
    limit_req zone=ip burst=20 nodelay;
    return 301 https://${redirectionDomainName}\$request_uri;
  }
}"
  SetFileContent "${httpsConfiguration}" "${httpsConfigurationPath}"
  RestartService 'nginx'
}
