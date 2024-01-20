#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/gitea/utilities.sh"
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

function SetupGitea () {
  InstallPackageIfNotExisting 'git'
  giteaApplicationName='gitea'
  giteaDatabaseName="${giteaApplicationName}db"
  giteaDataPath=/var/lib/gitea
  giteaConfigurationPath=/etc/gitea
  giteaConfigurationFilePath="${giteaConfigurationPath}"/app.ini
  giteaBinaryPath=/var/opt/gitea/gitea
  giteaBinaryDownloadPath=/tmp/gitea
  giteaEnvironmentVariables="USER=${giteaApplicationName} HOME=/home/${giteaApplicationName} GITEA_WORK_DIR=${giteaDataPath}"
  AskIfNotSet giteaDomainName "Enter your Gitea domain name"
  AskIfNotSet giteaInternalPort "Enter your Gitea internal port"
  AskIfNotSet giteaDatabasePassword "Enter your Gitea database password"
  AskIfNotSet giteaAdministratorUserName "Enter your Gitea administrator username"
  AskIfNotSet giteaAdministratorEmail "Enter your Gitea administrator email"
  AskIfNotSet giteaAdministratorPassword "Enter your Gitea administrator password"
  AskIfNotSet giteaSmtpHostName "Enter your Gitea SMTP hostname"
  AskIfNotSet giteaSmtpUserName "Enter your Gitea SMTP username" "${giteaApplicationName}@${giteaSmtpHostName:?}"
  AskIfNotSet giteaSmtpPassword "Enter your Gitea SMTP password"
  AskIfNotSet giteaSmtpPort "Enter your Gitea SMTP port" '465'
  CreateUserIfNotExisting "${giteaApplicationName}"
  CreatePostgreSqlDatabaseIfNotExisting "${giteaDatabaseName}"
  CreatePostgreSqlUserIfNotExisting "${giteaApplicationName}" "${giteaDatabasePassword:?}"
  GrantAllPrivilegesOnPostgreSqlDatabase "${giteaDatabaseName}" "${giteaApplicationName}"
  CreateDirectoryIfNotExisting "${giteaDataPath}"/custom
  CreateDirectoryIfNotExisting "${giteaDataPath}"/data
  CreateDirectoryIfNotExisting "${giteaDataPath}"/log
  CreateDirectoryIfNotExisting "$(dirname "${giteaBinaryPath}")"
  SetDirectoryOwnershipRecursively "${giteaDataPath}" "${giteaApplicationName}"
  SetDirectoryOwnershipRecursively "$(dirname "${giteaBinaryPath}")" "${giteaApplicationName}"
  SetDefaultDirectoryPermissions "$(dirname "${giteaBinaryPath}")"
  CreateDirectoryIfNotExisting "${giteaConfigurationPath}"
  SetDirectoryOwnership "${giteaConfigurationPath}" "${giteaApplicationName}" "${giteaApplicationName}"
  giteaLatestVersion=$(GetLatestGiteaVersion)
  giteaCurrentVersion=$(GetCurrentGiteaVersion)
  DownloadGiteaBinaryIfOutdated "${giteaLatestVersion}" "${giteaCurrentVersion}" "${giteaApplicationName}" "${giteaBinaryPath}" "${giteaBinaryDownloadPath}"
  giteaSecretKey=$(GetGiteaSecretKey 'SECRET_KEY')
  giteaInternalToken=$(GetGiteaSecretKey 'INTERNAL_TOKEN')
  giteaJwtSecret=$(GetGiteaSecretKey 'JWT_SECRET')
  fileContent="APP_NAME = Gitea: Git with a cup of tea
RUN_USER = ${giteaApplicationName}
RUN_MODE = prod

[database]
DB_TYPE  = postgres
HOST     = 127.0.0.1:5432
NAME     = ${giteaDatabaseName}
USER     = ${giteaApplicationName}
PASSWD   = ${giteaDatabasePassword}
SCHEMA   =
SSL_MODE = disable
CHARSET  = utf8
PATH     = /var/lib/gitea/data/gitea.db
LOG_SQL  = false

[repository]
ROOT = /var/lib/gitea/data/gitea-repositories

[server]
SSH_DOMAIN       = ${giteaDomainName:?}
DOMAIN           = ${giteaDomainName}
HTTP_PORT        = ${giteaInternalPort:?}
ROOT_URL         = https://${giteaDomainName}/
DISABLE_SSH      = false
SSH_PORT         = 22
LFS_START_SERVER = true
LFS_JWT_SECRET   = ${giteaJwtSecret}
OFFLINE_MODE     = false

[lfs]
PATH = /var/lib/gitea/data/lfs

[mailer]
ENABLED   = true
SMTP_ADDR = ${giteaSmtpHostName:?}
SMTP_PORT = ${giteaSmtpPort:?}
FROM      = ${giteaSmtpUserName:?}
USER      = ${giteaSmtpUserName:?}
PASSWD    = ${giteaSmtpPassword:?}

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
ROOT_PATH = /var/lib/gitea/log
ROUTER    = console

[repository.pull-request]
DEFAULT_MERGE_STYLE = merge

[repository.signing]
DEFAULT_TRUST_MODEL = committer

[security]
SECRET_KEY         = ${giteaSecretKey}
INSTALL_LOCK       = true
INTERNAL_TOKEN     = ${giteaInternalToken}
PASSWORD_HASH_ALGO = pbkdf2"
  SetFileContent "${fileContent}" "${giteaConfigurationFilePath}"
  SetFileOwnership "${giteaConfigurationFilePath}" "${giteaApplicationName}" "${giteaApplicationName}"
  CreateOrUpdateGiteaAdminstratorAccount "${giteaAdministratorUserName:?}" "${giteaAdministratorEmail:?}" "${giteaAdministratorPassword:?}" "${giteaConfigurationFilePath}" "${giteaDataPath}"
  CreateStartupService "${giteaApplicationName}" "${giteaBinaryPath} web --config ${giteaConfigurationFilePath}" "${giteaApplicationName}" "${giteaDataPath}" "${giteaEnvironmentVariables}"
  RestartService "${giteaApplicationName}"
}

function SetupGiteaWebServer () {
  giteaApplicationName='gitea'
  AskIfNotSet giteaDomainName "Enter your Gitea domain name"
  AskIfNotSet letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  AskIfNotSet giteaInternalPort "Enter your Gitea internal port"
  CreateProxyDomainName "${giteaApplicationName}" "${giteaDomainName}" "${giteaInternalPort}" "${letsEncryptEmail:?}"
  giteaContentSecurityPolicyConfigurationPath=/etc/nginx/sites-configuration/"${giteaApplicationName}"/"${giteaDomainName}"/content-security-policy.conf
  giteaContentSecurityPolicyConfiguration="add_header Content-Security-Policy \"default-src 'self' 'unsafe-inline' 'unsafe-eval' data:;\";"
  SetFileContent "${giteaContentSecurityPolicyConfiguration}" "${giteaContentSecurityPolicyConfigurationPath}"
  RestartService 'nginx'
}
