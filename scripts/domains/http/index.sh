#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/web-server/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"

function SetupHttpProxyServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  Ask letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  Ask httpInternalPort "Enter your application internal port"
  CreateProxyDomainName "${httpApplicationName:?}" "${domainName:?}" "${httpInternalPort:?}" "${letsEncryptEmail:?}"
  RestartService 'nginx'
}

function SetupHttpStaticServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  Ask letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  httpApplicationDeploymentPath=/var/www/"${httpApplicationName:?}"
  CreateStaticDomainName "${httpApplicationName:?}" "${domainName:?}" "${letsEncryptEmail:?}"
  CreateApplicationDeploymentUserThroughSsh "${httpApplicationName:?}" "${httpApplicationDeploymentPath}"
  SetDirectoryOwnershipRecursively "${httpApplicationDeploymentPath}" "${httpApplicationName:?}" 'www-data'
  SetDirectoryPermissionsRecursively "${httpApplicationDeploymentPath}" 775
  RestartService 'nginx'
}

function SetupHttpSpaServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  Ask letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  CreateSpaDomainName "${httpApplicationName:?}" "${domainName:?}" "${letsEncryptEmail:?}"
  CreateApplicationDeploymentUserThroughSsh "${httpApplicationName:?}" /var/www/"${httpApplicationName:?}"
  SetDirectoryOwnershipRecursively "${httpApplicationDeploymentPath}" "${httpApplicationName:?}" 'www-data'
  SetDirectoryPermissionsRecursively "${httpApplicationDeploymentPath}" 775
  RestartService 'nginx'
}

