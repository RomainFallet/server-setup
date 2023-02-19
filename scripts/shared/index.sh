#!/bin/bash

function CopyFileIfNotExisting () {
  filePath="${1}"
  destinationPath="${2}"
  if ! test -f "${destinationPath}"
  then
    sudo cp "${filePath}" "${destinationPath}"
  fi
}

function AppendTextInFileIfNotFound () {
  text="${1}"
  filePath="${2}"
  pattern=$(echo "${text}" | tr -d '\n')
  fileContent=$(< "${filePath}" tr -d '\n')
  if [[ "${fileContent}" != *"${pattern}"* ]]
  then
    echo "${text}" | sudo tee -a "${filePath}" > /dev/null
  fi
}

function ReplaceTextInFile () {
  regexPattern="${1}"
  replacementText="${2}"
  filePath="${3}"
  sudo sed -i'.tmp' -E "s|${regexPattern}|${replacementText}|g" "${filePath}"
  sudo rm -f "${filePath}".tmp
}

function LinesToArray () {
  text=${1}
  IFS=$'\n'
  read -ra array <<< "${text}"

  echo "${array[@]}"
}

export -f ReplaceTextInFile
export -f CopyFileIfNotExisting
export -f AppendTextInFileIfNotFound
export -f LinesToArray
