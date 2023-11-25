#!/bin/bash

function ExecShellScriptWithRoot () {
  directoryPath="${1}"
  pathToExecute="${2}"
  arguments="${3}"
  currentWorkingDirectory="${PWD}"
  cd "${directoryPath}" || exit
  if [[ -n "${arguments}" ]]; then
    sudo bash "${pathToExecute}" "${arguments}"
  else
    sudo bash "${pathToExecute}"
  fi
  cd "${currentWorkingDirectory}" || exit
}

function ExecShellScript () {
  directoryPath="${1}"
  pathToExecute="${2}"
  arguments="${3}"
  currentWorkingDirectory="${PWD}"
  cd "${directoryPath}" || exit
  if [[ -n "${arguments}" ]]; then
    bash "${pathToExecute}" "${arguments}"
  else
    bash "${pathToExecute}"
  fi
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
