#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/web-server/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"

function SetupWebProxyServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  Ask httpInternalPort "Enter your application internal port"
  Ask email "Enter your email address for Letsencrypt registration"
  CreateProxyDomainName "${httpApplicationName:?}" "${domainName:?}" "${httpInternalPort:?}" 'ask' "${email}"
  RestartService 'nginx'
}

function SetupWebStaticServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  httpApplicationDeploymentPath=/var/www/"${httpApplicationName:?}"
  CreateStaticDomainName "${httpApplicationName:?}" "${domainName:?}"
  CreateApplicationDeploymentUserThroughSsh "${httpApplicationName:?}" "${httpApplicationDeploymentPath}"
  SetDirectoryOwnershipRecursively "${httpApplicationDeploymentPath}" "${httpApplicationName:?}" 'www-data'
  SetDirectoryPermissionsRecursively "${httpApplicationDeploymentPath}" 775
  RestartService 'nginx'
}

function SetupWebRedirectionServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter the domain name you want to redirect"
  Ask redirectionDomainName "Enter the domain name redirection target"
  CreateRedirectionDomainName "${httpApplicationName}" "${domainName}" "${redirectionDomainName}"
}

function SetupWebSpaServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  httpApplicationDeploymentPath=/var/www/"${httpApplicationName:?}"
  CreateSpaDomainName "${httpApplicationName:?}" "${domainName:?}"
  CreateApplicationDeploymentUserThroughSsh "${httpApplicationName:?}" /var/www/"${httpApplicationName:?}"
  SetDirectoryOwnershipRecursively "${httpApplicationDeploymentPath}" "${httpApplicationName:?}" 'www-data'
  SetDirectoryPermissionsRecursively "${httpApplicationDeploymentPath}" 775
  RestartService 'nginx'
}

