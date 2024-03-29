#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/databases/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/packages/index.sh"

function SetupPhoenixApplication () {
  Ask applicationName "Enter your Phoenix application name (eg. my-awesome-app)"
  databaseName="${applicationName:?}db"
  dataPath=/var/lib/"${applicationName}"
  configurationPath=/etc/"${applicationName}"
  applicationPath=/var/opt/"${applicationName}"
  CreateApplicationDeploymentUserThroughSsh "${applicationName}" "${applicationPath}"
  Ask createPostgreSqlDatabase "Create a PostgreSql database? (y/n)" 'n'
  if [[ "${createPostgreSqlDatabase:?}" == 'y' ]]; then
    Ask databasePassword "Enter your database password"
    CreatePostgreSqlDatabaseIfNotExisting "${databaseName}"
    CreatePostgreSqlUserIfNotExisting "${applicationName}" "${databasePassword:?}"
    GrantAllPrivilegesOnPostgreSqlDatabase "${databaseName}" "${applicationName}"
  fi
  CreateDirectoryIfNotExisting "${dataPath}"
  CreateDirectoryIfNotExisting "${configurationPath}"
  CreateDirectoryIfNotExisting "${applicationPath}"
  SetDirectoryOwnershipRecursively "${dataPath}" "${applicationName}"
  SetDirectoryOwnershipRecursively "${configurationPath}" "${applicationName}"
  SetDirectoryOwnershipRecursively "${applicationPath}" "${applicationName}"
  SetDefaultDirectoryPermissions "${dataPath}"
  SetDefaultDirectoryPermissions "${configurationPath}"
  SetDefaultDirectoryPermissions "${applicationPath}"
  # CreateStartupService "${applicationName}" "/var/opt/${applicationName}/application.jar"
  # CreateStartupServiceWatcher "${applicationName}" /var/opt/"${applicationName}"
  # RestartService "${applicationName}"
  # RestartService "${applicationName}-watcher"
  # RestartServicePath "${applicationName}-watcher"
}
