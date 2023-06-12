#!/bin/bash

function CreateUserIfNotExisting () {
  userName="${1}"
  if ! id --user "${userName}" &> /dev/null; then
    sudo adduser --system --shell /bin/bash --group --disabled-password --home /home/"${userName}" "${userName}"
  fi
}

