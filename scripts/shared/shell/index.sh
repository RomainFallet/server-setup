#!/bin/bash

function ExecShellScriptWithRoot () {
  directoryPath="${1}"
  pathToExecute="${2}"
  cd "${directoryPath}" || exit
  sudo "${pathToExecute}"
  cd ~/ || exit
}

function SourceFileIfExisting () {
  filePath="${1}"
  if test -f "${filePath}"; then
    sudo bash -c ". ${filePath}"
  fi
}
