#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function CreateDailyCronJob () {
  name="${1}"
  command="${2}"
  fileContent="#!/bin/bash
set -e
${command}"
  filePath=/etc/cron.daily/"${name}"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
}

function CreateWeeklyCronJob () {
  name="${1}"
  command="${2}"
  fileContent="#!/bin/bash
set -e
${command}"
  filePath=/etc/cron.weekly/"${name}"
  SetFileContent "${fileContent}" "${filePath}"
  MakeFileExecutable "${filePath}"
}