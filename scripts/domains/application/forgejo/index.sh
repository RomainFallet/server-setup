#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/forgejo/utilities.sh"
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

function SetupForgejo () {
  InstallPackageIfNotExisting 'git'
  forgejoApplicationName='forgejo'
  forgejoDatabaseName="${forgejoApplicationName}db"
  forgejoDataPath=/var/lib/forgejo
  forgejoConfigurationPath=/etc/forgejo
  forgejoConfigurationFilePath="${forgejoConfigurationPath}"/app.ini
  forgejoBinaryPath=/var/opt/forgejo/forgejo
  forgejoBinaryDownloadPath=/tmp/forgejo
  forgejoEnvironmentVariables="USER=${forgejoApplicationName}
HOME=/home/${forgejoApplicationName}
FORGEJO_WORK_DIR=${forgejoDataPath}"
  forgejoEnvironmentPath=/home/"${forgejoApplicationName}"/environment
  AskIfNotSet forgejoDomainName "Enter your Forgejo domain name"
  AskIfNotSet forgejoInternalPort "Enter your Forgejo internal port"
  AskIfNotSet forgejoDatabasePassword "Enter your Forgejo database password"
  AskIfNotSet forgejoAdministratorUserName "Enter your Forgejo administrator username"
  AskIfNotSet forgejoAdministratorEmail "Enter your Forgejo administrator email"
  AskIfNotSet forgejoAdministratorPassword "Enter your Forgejo administrator password"
  AskIfNotSet forgejoSmtpHostName "Enter your Forgejo SMTP hostname"
  AskIfNotSet forgejoSmtpUserName "Enter your Forgejo SMTP username" "${forgejoApplicationName}@${forgejoSmtpHostName:?}"
  AskIfNotSet forgejoSmtpPassword "Enter your Forgejo SMTP password"
  AskIfNotSet forgejoSmtpPort "Enter your Forgejo SMTP port" '465'
  forgejoInstanceUrl="https://${forgejoDomainName:?}/"
  CreateUserIfNotExisting "${forgejoApplicationName}"
  CreatePostgreSqlDatabaseIfNotExisting "${forgejoDatabaseName}"
  CreatePostgreSqlUserIfNotExisting "${forgejoApplicationName}" "${forgejoDatabasePassword:?}"
  GrantAllPrivilegesOnPostgreSqlDatabase "${forgejoDatabaseName}" "${forgejoApplicationName}"
  CreateDirectoryIfNotExisting "${forgejoDataPath}"/custom
  CreateDirectoryIfNotExisting "${forgejoDataPath}"/data
  CreateDirectoryIfNotExisting "${forgejoDataPath}"/log
  CreateDirectoryIfNotExisting "$(dirname "${forgejoBinaryPath}")"
  SetDirectoryOwnershipRecursively "${forgejoDataPath}" "${forgejoApplicationName}"
  SetDirectoryOwnershipRecursively "$(dirname "${forgejoBinaryPath}")" "${forgejoApplicationName}"
  SetDefaultDirectoryPermissions "$(dirname "${forgejoBinaryPath}")"
  CreateDirectoryIfNotExisting "${forgejoConfigurationPath}"
  SetDirectoryOwnership "${forgejoConfigurationPath}" "${forgejoApplicationName}" "${forgejoApplicationName}"
  forgejoLatestVersion=$(GetLatestForgejoVersion)
  forgejoCurrentVersion=$(GetCurrentForgejoVersion)
  DownloadForgejoBinaryIfOutdated "${forgejoLatestVersion}" "${forgejoCurrentVersion}" "${forgejoApplicationName}" "${forgejoBinaryPath}" "${forgejoBinaryDownloadPath}"
  forgejoSecretKey=$(GetForgejoSecretKey 'SECRET_KEY')
  forgejoInternalToken=$(GetForgejoSecretKey 'INTERNAL_TOKEN')
  forgejoJwtSecret=$(GetForgejoSecretKey 'JWT_SECRET')
  fileContent="APP_NAME = Forgejo: Git with a cup of tea
RUN_USER = ${forgejoApplicationName}
RUN_MODE = prod

[database]
DB_TYPE  = postgres
HOST     = 127.0.0.1:5432
NAME     = ${forgejoDatabaseName}
USER     = ${forgejoApplicationName}
PASSWD   = ${forgejoDatabasePassword}
SCHEMA   =
SSL_MODE = disable
CHARSET  = utf8
PATH     = /var/lib/forgejo/data/forgejo.db
LOG_SQL  = false

[repository]
ROOT = /var/lib/forgejo/data/forgejo-repositories

[server]
SSH_DOMAIN       = ${forgejoDomainName:?}
DOMAIN           = ${forgejoDomainName}
HTTP_PORT        = ${forgejoInternalPort:?}
ROOT_URL         = ${forgejoInstanceUrl}
DISABLE_SSH      = false
SSH_PORT         = 22
LFS_START_SERVER = true
LFS_JWT_SECRET   = ${forgejoJwtSecret}
OFFLINE_MODE     = true

[lfs]
PATH = /var/lib/forgejo/data/lfs

[mailer]
ENABLED   = true
SMTP_ADDR = ${forgejoSmtpHostName:?}
SMTP_PORT = ${forgejoSmtpPort:?}
FROM      = ${forgejoSmtpUserName:?}
USER      = ${forgejoSmtpUserName:?}
PASSWD    = ${forgejoSmtpPassword:?}

[service]
REGISTER_EMAIL_CONFIRM            = true
ENABLE_NOTIFY_MAIL                = true
DISABLE_REGISTRATION              = true
ALLOW_ONLY_EXTERNAL_REGISTRATION  = false
ENABLE_CAPTCHA                    = false
REQUIRE_SIGNIN_VIEW               = false
DEFAULT_KEEP_EMAIL_PRIVATE        = true
DEFAULT_ALLOW_CREATE_ORGANIZATION = true
DEFAULT_ENABLE_TIMETRACKING       = true
NO_REPLY_ADDRESS                  = noreply.localhost

[openid]
ENABLE_OPENID_SIGNIN = false
ENABLE_OPENID_SIGNUP = false

[cron.update_checker]
ENABLED = false

[session]
PROVIDER = file

[log]
MODE      = console
LEVEL     = info
ROOT_PATH = /var/lib/forgejo/log

[repository.pull-request]
DEFAULT_MERGE_STYLE = merge

[repository.signing]
DEFAULT_TRUST_MODEL = committer

[security]
SECRET_KEY         = ${forgejoSecretKey}
INSTALL_LOCK       = true
INTERNAL_TOKEN     = ${forgejoInternalToken}
PASSWORD_HASH_ALGO = pbkdf2"
  SetFileContent "${fileContent}" "${forgejoConfigurationFilePath}"
  SetFileOwnership "${forgejoConfigurationFilePath}" "${forgejoApplicationName}" "${forgejoApplicationName}"
  SetFileContent "${forgejoEnvironmentVariables}" "${forgejoEnvironmentPath}"
  SetFileOwnership "${forgejoEnvironmentPath}" "${forgejoApplicationName}" "${forgejoApplicationName}"
  CreateStartupService "${forgejoApplicationName}" "${forgejoBinaryPath} web --config ${forgejoConfigurationFilePath}" "${forgejoApplicationName}" "${forgejoDataPath}" "${forgejoEnvironmentPath}"
  RestartService "${forgejoApplicationName}"
  timeToWaitInSeconds=1
  sleep "${timeToWaitInSeconds}"s
  CreateOrUpdateForgejoAdminstratorAccount "${forgejoAdministratorUserName:?}" "${forgejoAdministratorEmail:?}" "${forgejoAdministratorPassword:?}" "${forgejoConfigurationFilePath}" "${forgejoDataPath}"
  forgejoRunnerBinaryPath=/usr/local/bin/forgejo-runner
  forgejoRunnerBinaryDownloadPath=/tmp/forgejo-runner
  forgejoRunnerLatestVersion="$(GetLatestForgejoRunnerVersion)"
  forgejoRunnerCurrentVersion="$(GetCurrentForgejoRunnerVersion "${forgejoRunnerBinaryPath}")"
  DownloadForgejoRunnerBinaryIfOutdated "${forgejoRunnerLatestVersion}" "${forgejoRunnerCurrentVersion}" "${forgejoRunnerBinaryPath}" "${forgejoRunnerBinaryDownloadPath}"
  forgejoRunner1Name="forgejo-runner-1"
  CreateUserIfNotExisting "${forgejoRunner1Name}"
  forgejoRunner1Token=$(GetForgejoRunnerToken "${forgejoRunner1Name}")
  RegisterForgejoRunner "${forgejoRunner1Name}" "${forgejoRunner1Token}" "${forgejoInstanceUrl}" "${forgejoConfigurationFilePath}"
  CreateStartupService "${forgejoRunner1Name}" "${forgejoRunnerBinaryPath} daemon" "${forgejoRunner1Name}" "/home/${forgejoRunner1Name}"
  RestartService "${forgejoRunner1Name}"
}

function SetupForgejoWebServer () {
  forgejoApplicationName='forgejo'
  AskIfNotSet forgejoDomainName "Enter your Forgejo domain name"
  AskIfNotSet forgejoInternalPort "Enter your Forgejo internal port"
  CreateProxyDomainName "${forgejoApplicationName}" "${forgejoDomainName}" "${forgejoInternalPort}" 'default'
  forgejoContentSecurityPolicyConfigurationPath=/etc/nginx/sites-configuration/"${forgejoApplicationName}"/"${forgejoDomainName}"/content-security-policy.conf
  forgejoContentSecurityPolicyConfiguration="add_header Content-Security-Policy \"default-src 'self' 'unsafe-inline' 'unsafe-eval' data:;\";"
  SetFileContent "${forgejoContentSecurityPolicyConfiguration}" "${forgejoContentSecurityPolicyConfigurationPath}"
  RestartService 'nginx'
}
