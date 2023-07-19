#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/utilities.sh"

function SetupJavaApplication () {
  Ask applicationName "Enter your Java application name (eg. my-awesome-app)"
  databaseName="${applicationName}db"
  dataPath=/var/lib/"${applicationName}"
  configurationPath=/etc/"${applicationName}"
  applicationPath=/var/opt/"${applicationName}"
  sshDirectoryPath=/home/"${applicationName}"/.ssh
  sshAuthorizedKeyPath="${sshDirectoryPath}/authorized_keys"
  userDataPath=/home/"${applicationName}"/data
  CreateUserIfNotExisting "${applicationName}"
  CreateDirectoryIfNotExisting "${sshDirectoryPath}"
  CreateFileIfNotExisting "${sshAuthorizedKeyPath}"
  Ask continuousDeploymentPublicKey "Enter your continuous deployment machine SSH public key (ed25519 format)"
  AppendTextInFileIfNotFound "${continuousDeploymentPublicKey:?}" "${sshAuthorizedKeyPath}"
  SetDirectoryOwnershipRecursively "${sshDirectoryPath}" "${applicationName}"
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
  CreateDirectorySymbolicLinkIfNotExisting "${userDataPath}" "${applicationPath}"
  SetSymbolicLinkOwnership "${userDataPath}" "${applicationName}"
  CreateStartupService "${applicationName}" "/usr/bin/java -jar /var/opt/${applicationName}/application.jar"
  CreateStartupServiceWatcher "${applicationName}" /var/opt/"${applicationName}"
  RestartService "${applicationName}"
  RestartService "${applicationName}-watcher"
  RestartServicePath "${applicationName}-watcher"
}
