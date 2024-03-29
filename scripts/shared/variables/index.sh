#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"

function ToLowerCase() {
  text="${1}"
  echo "${text}" | awk '{print tolower($0)}'
}

function ToKebabCase() {
  text="${1}"
  textInLowerCase=$(ToLowerCase "${text}")
  echo "${textInLowerCase}" | sed -E 's/\s/-/g'
}

function UpperCaseToCamelCase() {
  text="${1}"
  textInLowerCase=$(ToLowerCase "${text}")
  echo "${textInLowerCase}" | sed -E 's/_(.)/\U\1/g'
}

function Trim() {
  text="${1}"
  echo "${text}" | (sed 's|"|\\"|g' || true)| xargs
}

function AskIfNotSet() {
  variableName="${1}"
  askText="${2}"
  defaultValue="${3}"
  existingValue=$(GetConfigurationFileValue /etc/server-setup/main.conf "${variableName}")

  if [[ -n "${existingValue}" ]]; then
    defaultValue="${existingValue}"
  fi
  if [[ -z "${!variableName}" ]] && [[ -z "${defaultValue}" ]]; then
    read -r -p "${askText}: " "${variableName?}"
  fi
  if [[ -z "${!variableName}" ]] && [[ -n "${defaultValue}" ]]; then
    read -r -p "${askText} [${defaultValue}]: " "${variableName?}"
  fi
  if [[ -z "${!variableName}" ]] && [[ -n "${defaultValue}" ]]; then
    declare -g "${variableName}"="${defaultValue}"
  fi
  if [[ -z "${!variableName}" ]] && [[ -z "${defaultValue}" ]]; then
    AskIfNotSet "${variableName}" "${askText}" "${defaultValue}"
  fi
  if [[ -n "${!variableName}" ]]; then
    SetConfigurationFileValue /etc/server-setup/main.conf "${variableName}" "${!variableName}"
  fi
}

function Ask() {
  variableName="${1}"
  askText="${2}"
  defaultValue="${3}"

  if [[ -z "${!variableName}" ]] && [[ -z "${defaultValue}" ]]; then
    read -r -p "${askText}: " "${variableName?}"
  fi
  if [[ -z "${!variableName}" ]] && [[ -n "${defaultValue}" ]]; then
    read -r -p "${askText} [${defaultValue}]: " "${variableName?}"
  fi
  if [[ -z "${!variableName}" ]] && [[ -n "${defaultValue}" ]]; then
    declare -g "${variableName}"="${defaultValue}"
  fi
  if [[ -z "${!variableName}" ]]; then
    Ask "${variableName}" "${askText}"
  fi
}

function ReplaceText () {
  regexPattern="${1}"
  replacementText="${2}"
  inputText="${3}"
  echo "${inputText}" | sed --regexp-extended "s|${regexPattern}|${replacementText}|g"
}
