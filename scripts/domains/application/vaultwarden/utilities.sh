#!/bin/bash

function SelectAppropriateVaultwardenArchitecture () {
  processorArchitecture=$(uname -m)
  if [[ "${processorArchitecture}" == 'aarch64' ]]; then
    echo "linux/arm64"
  elif [[ "${processorArchitecture}" == 'x86_64' ]]; then
    echo "linux/amd64"
  else
    echo "linux/amd64"
  fi
}
