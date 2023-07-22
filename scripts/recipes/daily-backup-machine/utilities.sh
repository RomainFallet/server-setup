#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/users/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function AskForExternalHardDrive () {
  AskIfNotSet useExternalHardDrive "Are you using an external hard drive at /dev/sda? (y/n)" 'n'
}

function AskDailyBackupMachineActions () {
  Ask dailyBackupMachineAction "What do you want to do?
  - Nothing [0]
  - Create a user [1]"
  if [[ "${dailyBackupMachineAction:?}" == '1' ]]; then
    Ask usernameToCreate "Enter the username"
    CreateUserIfNotExisting "${usernameToCreate:?}"
  fi
}

function LinkHomeFolderToExternalDiskIfNeeded () {
  if [[ "${useExternalHardDrive:?}" == 'y' ]]; then
    for directoryPath in /home/*/
    do      directoryPath=${directoryPath%*/}
      username=${directoryPath##*/}
      sourcePath=/mnt/sda/"${username}"
      targetPath=/home/"${username}"/data
      echo "Linking folder to external disk"
      echo "username: ${username}"
      echo "sourcePath: ${sourcePath}"
      echo "targetPath: ${targetPath}"
      # shellcheck disable=SC2065
      if ! test -d /mnt/sda/"${username}" > /dev/null; then
        CreateDirectoryIfNotExisting "${sourcePath}"
        SetDirectoryOwnership "${sourcePath}" "${username}"
      fi
      CreateDirectorySymbolicLinkIfNotExisting "${targetPath}" "${sourcePath}"
      SetSymbolicLinkOwnership "${targetPath}" "${username}"
    done

  fi
}
