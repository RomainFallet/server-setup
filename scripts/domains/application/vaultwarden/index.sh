#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/shell/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/vaultwarden/utilities.sh"

function SetupVaultwarden () {
  vaultwardenApplicationName='vaultwarden'
  vaultwardenPath=/var/opt/vaultwarden
  vaultwardenDataPath=/var/lib/vaultwarden
  vaultwardenLogPath=/var/lib/vaultwarden/vaultwarden.log
  vaultwardenBinaryPath="${vaultwardenPath}/vaultwarden"
  vaultwardenOutputPath=/tmp/vaultwarden-output
  vaultwardenDatabaseName="${vaultwardenApplicationName}db"
  vaultwardenEnvironmentPath=/home/"${vaultwardenApplicationName}"/environment
  vaultwardenWebvaultPath=/var/opt/vaultwarden/web-vault
  AskIfNotSet vaultwardenDomainName "Enter your Vaultwarden domain name"
  AskIfNotSet vaultwardenInternalPort "Enter your Vaultwarden internal port"
  AskIfNotSet vaultwardenDatabasePassword "Enter your Vaultwarden database password"
  AskIfNotSet vaultwardenSmtpHostName "Enter your Vaultwarden SMTP hostname"
  AskIfNotSet vaultwardenSmtpUserName "Enter your Vaultwarden SMTP username" "${vaultwardenApplicationName}@${vaultwardenSmtpHostName:?}"
  AskIfNotSet vaultwardenSmtpPassword "Enter your Vaultwarden SMTP password"
  AskIfNotSet vaultwardenSmtpPort "Enter your Vaultwarden SMTP port" '465'
  AskIfNotSet vaultwardenAdministratorPassword "Enter your Vaultwarden administrator password"
  AskIfNotSet configureVaultwardenPortForwarding 'Forward vaultwarden port to remote machine? (y/n)' 'n'
  if [[ "${configureVaultwardenPortForwarding?:}" == 'y' ]]; then
    ForwardPortToRemoteServer "${vaultwardenInternalPort}" "vaultwarden-port-forwarding"
  fi
  ConfigureVaultwarden "${vaultwardenApplicationName}" "${vaultwardenDataPath}" "${vaultwardenLogPath}" "${vaultwardenDatabaseName}" "${vaultwardenDatabasePassword}" "${vaultwardenAdministratorPassword:?}" "${vaultwardenDomainName}" "${vaultwardenSmtpHostName}" "${vaultwardenSmtpUserName}" "${vaultwardenSmtpPassword}" "${vaultwardenSmtpPort}" "${vaultwardenEnvironmentPath}" "${vaultwardenInternalPort}" "${vaultwardenWebvaultPath}"
  CreateUserIfNotExisting "${vaultwardenApplicationName}"
  CreatePostgreSqlUserIfNotExisting "${vaultwardenApplicationName}" "${vaultwardenDatabasePassword:?}"
  CreatePostgreSqlDatabaseIfNotExisting "${vaultwardenDatabaseName}"
  GrantAllPrivilegesOnPostgreSqlDatabase "${vaultwardenDatabaseName}" "${vaultwardenApplicationName}"
  CreateDirectoryIfNotExisting "${vaultwardenPath}"
  CreateDirectoryIfNotExisting "${vaultwardenDataPath}"
  SetDirectoryOwnershipRecursively "${vaultwardenDataPath}" "${vaultwardenApplicationName}"
  CreateDirectoryIfNotExisting "${vaultwardenOutputPath}"
  DownloadVaultwardenIfOutdated "${vaultwardenApplicationName}" "${vaultwardenBinaryPath}" "${vaultwardenOutputPath}" "${vaultwardenPath}"
  SetDirectoryOwnershipRecursively "${vaultwardenPath}" "${vaultwardenApplicationName}"
  CreateStartupService "${vaultwardenApplicationName}" "${vaultwardenBinaryPath}" "${vaultwardenApplicationName}" "${vaultwardenPath}" "${vaultwardenEnvironmentPath}" 'postgresql.service'
  RestartService "${vaultwardenApplicationName}"
}

function SetupVaultwardenWebServer () {
  vaultwardenApplicationName='vaultwarden'
  AskIfNotSet vaultwardenDomainName "Enter your Vaultwarden domain name"
  AskIfNotSet letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  AskIfNotSet vaultwardenInternalPort "Enter your Vaultwarden internal port"
  CreateProxyDomainName "${vaultwardenApplicationName}" "${vaultwardenDomainName:?}" "${vaultwardenInternalPort:?}" "${letsEncryptEmail:?}" 'default'
  vaultwardenContentSecurityPolicyConfigurationPath=/etc/nginx/sites-configuration/"${vaultwardenApplicationName}"/"${vaultwardenDomainName}"/content-security-policy.conf
  vaultwardenContentSecurityPolicyConfiguration="add_header Content-Security-Policy \"default-src 'self' 'wasm-eval' 'unsafe-inline' data:;\";"
  SetFileContent "${vaultwardenContentSecurityPolicyConfiguration}" "${vaultwardenContentSecurityPolicyConfigurationPath}"
  RestartService 'nginx'
}
