#!/bin/bash

function ExecShellScriptWithRoot () {
  directoryPath="${1}"
  pathToExecute="${2}"
  cd "${directoryPath}" || exit
  sudo "${pathToExecute}"
  cd ~/ || exit
}
