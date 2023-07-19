#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function CreateUserIfNotExisting () {
  userName="${1}"
  if ! id --user "${userName}" &> /dev/null; then
    sudo adduser --system --shell /bin/bash --group --disabled-password --home /home/"${userName}" "${userName}"
  fi
}

function CreateApplicationDeploymentUserThroughSsh () {
  userName="${1}"
  deploymentPath="${2}"
  sshDirectoryPath=/home/"${userName}"/.ssh
  sshAuthorizedKeyPath="${sshDirectoryPath}/authorized_keys"
  userDataPath=/home/"${userName}"/data
  CreateUserIfNotExisting "${userName}"
  CreateDirectoryIfNotExisting "${sshDirectoryPath}"
  CreateFileIfNotExisting "${sshAuthorizedKeyPath}"
  Ask continuousDeploymentPublicKey "Enter your continuous deployment machine SSH public key (ed25519 format)"
  AppendTextInFileIfNotFound "${continuousDeploymentPublicKey:?}" "${sshAuthorizedKeyPath}"
  SetDirectoryOwnershipRecursively "${sshDirectoryPath}" "${userName}"
  CreateDirectorySymbolicLinkIfNotExisting "${userDataPath}" "${deploymentPath}"
  SetSymbolicLinkOwnership "${userDataPath}" "${userName}"
}
