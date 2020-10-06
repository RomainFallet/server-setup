#!/bin/bash

# Ask for username if not provided
if [[ -z ${sambausername} ]]; then
  read -r -p "Choose the name of the Samba user: " sambausername
  if [[ -z ${sambausername} ]]; then
    echo "User name must not be empty." 1>&2
    exit 1
  fi
fi

# Check if the user exists
USER_ID=$(id -u "${sambausername}" 2> /dev/null)
if [[ -n ${USER_ID} ]]; then
  # Ask for password if not provided
  if [[ -z ${password} ]]; then
    read -r -p "Choose the new user password: " password
    if [[ -z ${password} ]]; then
      echo "Password must not be empty." 1>&2
      exit 1
    fi
  fi
fi
