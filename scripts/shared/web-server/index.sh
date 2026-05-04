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
  email="${4}"
  websocketConfiguration=$(ConfigureWebsocket 'ask' "${applicationName}")
  disableRouteConfiguration=$(DisableAccessToSpecificRoute)
  GenerateTlsCertificate "${applicationName}" "${domainName}" "${email}"
  sslCertificatePath="/etc/letsencrypt/live/${domainName}/fullchain.pem"
  sslCertificateKeyPath="/etc/letsencrypt/live/${domainName}/privkey.pem"
  if sudo test -f "${sslCertificatePath}" && sudo test -f "${sslCertificateKeyPath}"; then
    httpsConfigurationPath=/etc/nginx/sites-configuration/"${applicationName}"/"${domainName}"/https.conf
    httpsConfiguration="# ============================================================
# Generic reverse proxy
#
# Responsibility split:
# - Nginx: transport (TLS, HTTP), networking, basic protections
# - Vaultwarden: application logic (CSP, cache, API behavior, etc.)
#
# Intentionally minimal: avoids overriding application behavior
# ============================================================


# Upstream definition with keepalive to avoid reopening a TCP
# connection for every request (important with HTTP/1.1 backend)
upstream ${applicationName} {
    server 127.0.0.1:${internalPort};
    keepalive 32;
}

server {
    # --------------------------------------------------------
    # HTTP/2 and HTTP/1.1 fallback
    # --------------------------------------------------------
    listen 443      ssl;
    listen [::]:443 ssl;
    http2 on;

    # Virtual host configuration
    server_name ${domainName};

    # --------------------------------------------------------
    # Main application endpoint
    # --------------------------------------------------------
    location / {
        # Forward original client information to backend
        # Required for correct logging, security checks and URL generation
        proxy_set_header Host \$host;
        proxy_set_header Origin \$scheme://\$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header X-Forwarded-Host \$host;
        proxy_set_header X-Forwarded-Port \$server_port;

        # Proxy to backend
        proxy_pass http://${applicationName};

        # Max body size
        client_max_body_size 500M;

        # Timeouts tuned to avoid hanging connections
        proxy_read_timeout 300s;
        proxy_send_timeout 300s;
        client_body_timeout 300s;

        # Disable buffering: ensures correct streaming behavior and prevents
        # partial transfers with backends that do not tolerate buffering well
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_cache off;
    }
    ${websocketConfiguration}
    ${disableRouteConfiguration}
    # --------------------------------------------------------
    # Logging (dedicated per vhost)
    # --------------------------------------------------------
    error_log  /var/log/nginx/${applicationName}.error.log error;
    access_log /var/log/nginx/${applicationName}.access.log;

    # --------------------------------------------------------
    # TLS configuration (Let's Encrypt)
    # Modern TLS setup: TLS 1.3 only, secure curves, no tickets
    # --------------------------------------------------------
    ssl_certificate     /etc/letsencrypt/live/${domainName}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${domainName}/privkey.pem;
    ssl_protocols TLSv1.3;
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    ssl_ecdh_curve X25519:secp384r1;
    # Disable 0-RTT to prevent replay attacks
    ssl_early_data off;

    # --------------------------------------------------------
    # HSTS (Strict Transport Security)
    # Forces clients to use HTTPS after first successful request
    # --------------------------------------------------------
    add_header Strict-Transport-Security \"max-age=63072000; includeSubDomains; preload\" always;

    # --------------------------------------------------------
    # Generic security headers (infra-level, app-agnostic)
    # These do NOT interfere with application logic
    # --------------------------------------------------------
    proxy_hide_header X-Content-Type-Options;
    add_header X-Content-Type-Options \"nosniff\" always;

    # Privacy-focused referrer policy
    # "strict-origin-when-cross-origin" prevents leaking sensitive data
    # while maintaining compatibility with external services
    proxy_hide_header Referrer-Policy;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
  }"
    SetFileContent "${httpsConfiguration}" "${httpsConfigurationPath}"
    RestartService 'nginx'
  fi
}

function CreateStaticDomainName () {
  applicationName="${1}"
  domainName="${2}"
  cspBehavior="${3}"
  GenerateTlsCertificate "${applicationName}" "${domainName}"
  sslCertificatePath="/etc/letsencrypt/live/${domainName}/fullchain.pem"
  sslCertificateKeyPath="/etc/letsencrypt/live/${domainName}/privkey.pem"
  if sudo test -f "${sslCertificatePath}" && sudo test -f "${sslCertificateKeyPath}"; then
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

    ssl_certificate     ${sslCertificatePath};
    ssl_certificate_key ${sslCertificateKeyPath};

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
  fi
}

function CreateSpaDomainName () {
  applicationName="${1}"
  domainName="${2}"
  cspBehavior="${3}"
  GenerateTlsCertificate "${applicationName}" "${domainName}"
  sslCertificatePath="/etc/letsencrypt/live/${domainName}/fullchain.pem"
  sslCertificateKeyPath="/etc/letsencrypt/live/${domainName}/privkey.pem"
  if sudo test -f "${sslCertificatePath}" && sudo test -f "${sslCertificateKeyPath}"; then
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
  fi
}

function CreateRedirectionDomainName () {
  applicationName="${1}"
  domainName="${2}"
  redirectionDomainName="${3}"
  GenerateTlsCertificate "${applicationName}" "${domainName}"
  sslCertificatePath="/etc/letsencrypt/live/${domainName}/fullchain.pem"
  sslCertificateKeyPath="/etc/letsencrypt/live/${domainName}/privkey.pem"
  if sudo test -f "${sslCertificatePath}" && sudo test -f "${sslCertificateKeyPath}"; then
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
  fi
}
