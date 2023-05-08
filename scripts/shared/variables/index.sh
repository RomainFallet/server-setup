#!/bin/bash

function ToLowerCase() {
  text="${1}"
  echo "${text}" | awk '{print tolower($0)}'
}

function AskIfNotSet() {
  variableName="${1}"
  askText="${2}"
  defaultValue="${3}"
  if [[ -z "${!variableName}" ]]; then
    read -r -p "${askText}: " "${variableName?}"
    if [[ -z "${!variableName}" ]] && [[ -n "${defaultValue}" ]]; then
      declare -g "${variableName}"="${defaultValue}"
    fi
    if [[ -z "${!variableName}" ]] && [[ -z "${defaultValue}" ]]; then
      AskIfNotSet "${variableName}" "${askText}" "${defaultValue}"
    fi
  fi
}

