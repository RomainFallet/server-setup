#!/bin/bash

function ExecShellScriptWithRoot () {
  directoryPath="${1}"
  pathToExecute="${2}"
  currentWorkingDirectory="${PWD}"
  cd "${directoryPath}" || exit
  sudo bash "${pathToExecute}"
  cd "${currentWorkingDirectory}" || exit
}

function SourceFileIfExisting () {
  filePath="${1}"
  if test -f "${filePath}"; then
    sudo bash -c ". ${filePath}"
  fi
}

function DisplayMessage () {
  message="${1}"
  echo "${message}"
}
