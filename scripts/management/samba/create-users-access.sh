#!/bin/bash

set -e

while read -r line; do
  userName=$(echo "${line}" | cut -d: -f1)
  homeDirectory=$(echo "${line}" | cut -d: -f6)
  if echo "${homeDirectory}" | grep '/home' > /dev/null
  then
    if [[ "${userName}" != 'syslog' ]]
    then
      # shellcheck source=./create-user-access.sh
      source ~/server-setup/scripts/management/samba/create-user-access.sh "${userName}"
    fi
  fi
done </etc/passwd
