#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/web-server/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

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
  CreateStaticDomainName "${httpApplicationName:?}" "${domainName:?}" "${letsEncryptEmail:?}"
  RestartService 'nginx'
}

function SetupHttpSpaServer () {
  Ask httpApplicationName "Enter your HTTP application name (eg. my-awesome-app)"
  Ask domainName "Enter your domain name"
  Ask letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  CreateSpaDomainName "${httpApplicationName:?}" "${domainName:?}" "${letsEncryptEmail:?}"
  RestartService 'nginx'
}

