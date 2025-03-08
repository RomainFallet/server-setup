#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/listmonk/utilities.sh"
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

function SetupListmonk () {
  listmonkApplicationName='listmonk'
  listmonkPath=/var/opt/listmonk
  listmonkBinaryDirectoryPath=/var/opt/listmonk/bin
  listmonkBinaryPath="${listmonkBinaryDirectoryPath}"/listmonk
  listmonkConfigurationFilePath=/etc/listmonk/config.toml
  listmonkDownloadPath=/tmp/listmonk.tar.gz
  listmonkDatabaseName="${listmonkApplicationName}db"
  listmonkDataDirectory=/var/lib/listmonk
  listmonkFilesDirectory="${listmonkDataDirectory}"/files
  listmonkTemplatesDirectory="${listmonkFilesDirectory}"/email-templates
  listmonkPublicDirectory="${listmonkFilesDirectory}"/public
  AskIfNotSet listmonkDatabasePassword "Enter your Listmonk database password"
  AskIfNotSet listmonkInternalPort "Enter your Listmonk internal port"
  AskIfNotSet listmonkAdministratorUserName "Enter your Listmonk administrator username"
  AskIfNotSet listmonkAdministratorPassword "Enter your Listmonk administrator password"
  CreateUserIfNotExisting "${listmonkApplicationName}"
  CreatePostgreSqlUserIfNotExisting "${listmonkApplicationName}" "${listmonkDatabasePassword:?}"
  CreatePostgreSqlDatabaseIfNotExisting "${listmonkDatabaseName}"
  GrantAllPrivilegesOnPostgreSqlDatabase "${listmonkDatabaseName}" "${listmonkApplicationName}"
  CreateDirectoryIfNotExisting "${listmonkFilesDirectory}"
  CreateDirectoryIfNotExisting "${listmonkTemplatesDirectory}"
  CreateDirectoryIfNotExisting "${listmonkPublicDirectory}"
  CreateDirectoryIfNotExisting "${listmonkBinaryDirectoryPath}"
  SetDirectoryOwnershipRecursively "${listmonkDataDirectory}" "${listmonkApplicationName}"
  SetDirectoryOwnershipRecursively "${listmonkPath}" "${listmonkApplicationName}"
  DownloadListmonkIfOutdated "${listmonkDownloadPath}" "${listmonkBinaryPath}"
  ConfigureListmonk "${listmonkConfigurationFilePath}" "${listmonkInternalPort}" "${listmonkApplicationName}" "${listmonkDatabasePassword}" "${listmonkDatabaseName}" "${listmonkAdministratorUserName:?}" "${listmonkAdministratorPassword:?}"
  ConfigureListmonkDatabase "${listmonkBinaryPath}" "${listmonkConfigurationFilePath}" "${listmonkApplicationName}"
  CreateStartupService "${listmonkApplicationName}" "${listmonkBinaryPath} --config ${listmonkConfigurationFilePath} --static-dir ${listmonkFilesDirectory}" "${listmonkApplicationName}" "/var/opt/listmonk/" '' 'postgresql.service'
  RestartService "${listmonkApplicationName}"
  CreateProxyDomainName "${listmonkApplicationName}" "${listmonkDomainName:?}" "${listmonkInternalPort:?}" 'default'
  listmonkContentSecurityPolicyConfigurationPath=/etc/nginx/sites-configuration/"${listmonkApplicationName}"/"${listmonkDomainName}"/content-security-policy.conf
  listmonkContentSecurityPolicyConfiguration="add_header Content-Security-Policy \"default-src 'self' 'unsafe-inline' data:;\";"
  SetFileContent "${listmonkContentSecurityPolicyConfiguration}" "${listmonkContentSecurityPolicyConfigurationPath}"
  RestartService 'nginx'
}
