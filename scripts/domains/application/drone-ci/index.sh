#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/drone-ci/utilities.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/web-server/index.sh"
# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function SetupDroneCi () {
  droneApplicationName='drone-ci'
  droneDataPath=/var/lib/"${droneApplicationName}"
  AskIfNotSet droneDomainName "Enter your Drone CI domain name"
  AskIfNotSet droneInternalPort "Enter your Drone CI internal port"
  AskIfNotSet droneSharedSecretKey "Enter your Drone CI shared secret key"
  AskIfNotSet giteaBaseUrl "Enter your Gitea instance base URL"
  AskIfNotSet giteaClientId "Enter your Gitea client id"
  AskIfNotSet giteaClientSecret "Enter your Gitea client secret"
  CreateUserIfNotExisting "${droneApplicationName}"
  CreateDirectoryIfNotExisting "${droneDataPath}"
  SetDirectoryOwnershipRecursively "${droneDataPath}" "${droneApplicationName}"
  CreateDroneCiDockerContainer "${droneApplicationName}" "${droneDataPath}" "${droneDomainName}" "${droneInternalPort}" "${droneSharedSecretKey}" "${giteaBaseUrl?:}" "${giteaClientId}" "${giteaClientSecret}"
  CreateStartupService "${droneApplicationName}" "sudo docker start ${droneApplicationName}" 'root' "${droneDataPath}" '' 'docker.service'
  RestartService "${droneApplicationName}"
}

function SetupDroneCiWebServer () {
  droneApplicationName='drone-ci'
  AskIfNotSet droneDomainName "Enter your Drone CI domain name"
  AskIfNotSet letsEncryptEmail "Enter an email to request a LetsEncrypt's TLS certificate for your domain name"
  AskIfNotSet droneInternalPort "Enter your Drone CI internal port"
  CreateProxyDomainName "${droneApplicationName}" "${droneDomainName}" "${droneInternalPort}" "${letsEncryptEmail:?}" 'default'
  droneContentSecurityPolicyConfigurationPath=/etc/nginx/sites-configuration/"${droneApplicationName}"/"${droneDomainName}"/content-security-policy.conf
  droneContentSecurityPolicyConfiguration="add_header Content-Security-Policy \"default-src 'self' 'unsafe-inline' 'unsafe-eval' data:;\";"
  SetFileContent "${droneContentSecurityPolicyConfiguration}" "${droneContentSecurityPolicyConfigurationPath}"
  RestartService 'nginx'
}
