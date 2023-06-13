#!/bin/bash

function CloneRepositoryIfNotExisting () {
  url="${1}"
  path="${2}"
  if ! test -d "${path}"
  then
    git clone "${url}"
  fi
}

function CheckoutRepository () {
  path="${1}"
  gitRreference="${2}"
  cd "${path}" || exit
  git fetch origin main
  git checkout "${gitRreference}"
  cd ~/ || exit
}
