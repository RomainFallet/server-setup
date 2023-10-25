#!/bin/bash

function CopyFileIfNotExisting () {
  filePath="${1}"
  destinationPath="${2}"
  if ! test -f "${destinationPath}"
  then
    sudo cp "${filePath}" "${destinationPath}"
  fi
}

function CopyDirectory () {
  directoryPath="${1}"
  destinationPath="${2}"
  sudo cp --archive "${directoryPath}" "${destinationPath}"
}

function BackupFile () {
  filePath="${1}"
  fileName=$(basename "${filePath}")
  directoryPath=$(dirname "${filePath}")
  destinationPath="${directoryPath}/.${fileName}.backup"
  CopyFileIfNotExisting "${filePath}" "${destinationPath}"
}

function AppendTextInFileIfNotFound () {
  text="${1}"
  filePath="${2}"
  pattern=$(echo "${text}" | tr -d '\n')
  fileContent=$(sudo cat "${filePath}")
  fileContentWithoutNewLines=$(echo "${fileContent}" | tr -d '\n')
  if [[ "${fileContentWithoutNewLines}" != *"${pattern}"* ]]
  then
    echo "${text}" | sudo tee -a "${filePath}" > /dev/null
  fi
}

function ReplaceTextInFile () {
  regexPattern="${1}"
  replacementText="${2}"
  filePath="${3}"
  sudo sed -i'.tmp' --regexp-extended "s|${regexPattern}|${replacementText}|g" "${filePath}"
  sudo rm -f "${filePath}".tmp
}

function LinesToArray () {
  text=${1}
  IFS=$'\n'
  read -ra array <<< "${text}"

  echo "${array[@]}"
}

function CreateDirectoryIfNotExisting () {
  directoryPath="${1}"
  sudo mkdir -p "${directoryPath}"
}

function CreateFileIfNotExisting () {
  filePath="${1}"
  sudo touch "${filePath}"
}

function SetFileContent () {
  fileContent="${1}"
  filePath="${2}"
  directoryPath=$(dirname "${filePath}")
  CreateDirectoryIfNotExisting "${directoryPath}"
  echo "${fileContent}" | sudo tee "${filePath}" > /dev/null
}

function MakeFileExecutable () {
  filePath="${1}"
  sudo chmod u+x "${filePath}"
}

function RemoveFile () {
  filePath="${1}"
  sudo rm --force "${filePath}"
}

function RemoveDirectory () {
  directoryPath="${1}"
  sudo rm --force --recursive "${directoryPath}"
}

function CopyFile () {
  filePath="${1}"
  destinationPath="${2}"
  sudo cp --force "${filePath}" "${destinationPath}"
}

function DownloadFile () {
  url="${1}"
  destinationPath="${2}"
  sudo wget "${url}" --output-document "${destinationPath}"
}

function ExctractTarFile () {
  sourcePath="${1}"
  destinationPath="${2}"
  sudo tar -xvzf "${sourcePath}" -C "${destinationPath}"
}

function SetDefaultDirectoryPermissions () {
  directoryPath="${1}"
  sudo chmod -R 750 "${directoryPath}"
}

function SetDirectoryPermissions () {
  directoryPath="${1}"
  permissions="${2}"
  sudo chmod "${permissions}" "${directoryPath}"
}

function SetFilePermissions () {
  filePath="${1}"
  permissions="${2}"
  sudo chmod "${permissions}" "${filePath}"
}

function SetDirectoryPermissionsRecursively () {
  directoryPath="${1}"
  permissions="${2}"
  sudo chmod -R "${permissions}" "${directoryPath}"
}

function SetDirectoryOwnershipRecursively () {
  directoryPath="${1}"
  userName="${2}"
  groupName="${3}"
  if [[ -z "${groupName}" ]]; then
    groupName="${userName}"
  fi
  sudo chown -R "${userName}":"${groupName}" "${directoryPath}"
}

function SetDirectoryOwnership () {
  directoryPath="${1}"
  userName="${2}"
  groupName="${3}"
  if [[ -z "${groupName}" ]]; then
    groupName="${userName}"
  fi
  sudo chown "${userName}":"${groupName}" "${directoryPath}"
}

function SetFileOwnership () {
  filePath="${1}"
  userName="${2}"
  groupName="${3}"
  if [[ -z "${groupName}" ]]; then
    groupName="${userName}"
  fi
  sudo chown "${userName}":"${groupName}" "${filePath}"
}

function SetSymbolicLinkOwnership () {
  symlinkPath="${1}"
  userName="${2}"
  groupName="${3}"
  if [[ -z "${groupName}" ]]; then
    groupName="${userName}"
  fi
  sudo chown --no-dereference "${userName}":"${groupName}" "${symlinkPath}"
}

function GetConfigurationFileValue () {
  filePath="${1}"
  key="${2}"
  if sudo test -f "${filePath}"; then
    sudo awk "/^${key}/{print \$3}" "${filePath}"
  fi
}

function SetConfigurationFileValue () {
  filePath="${1}"
  key="${2}"
  value="${3}"
  ReplaceTextInFile "${key}\s=\s.*" "${key} = ${value}" "${filePath}"
  AppendTextInFileIfNotFound "${key} = ${value}" "${filePath}"
}

function CreateFileSymbolicLinkIfNotExisting () {
  symbolicLinkPath="${1}"
  targetedFilePath="${2}"
  if ! sudo test -f "${symbolicLinkPath}"; then
    sudo ln -s "${targetedFilePath}" "${symbolicLinkPath}"
  fi
}

function CreateDirectorySymbolicLinkIfNotExisting () {
  symbolicLinkPath="${1}"
  targetedFilePath="${2}"
  if ! sudo test -d "${symbolicLinkPath}"; then
    sudo ln -s "${targetedFilePath}" "${symbolicLinkPath}"
  fi
}

function MakeFileProtected () {
  filePath="${1}"
  sudo chattr -f +i "${filePath}"
}

function MakeFileUnprotected () {
  filePath="${1}"
  sudo chattr -f -i "${filePath}"
}

function SetJsonValueInFile () {
  filePath="${1}"
  key="${2}"
  value="${3}"
  rm --force /tmp/file.json
  updatedJson=$(sudo jq "${key} = ${value}" "${filePath}")
  echo "${updatedJson}" | tee /tmp/file.json > /dev/null
  sudo mv /tmp/file.json "${filePath}"
}
