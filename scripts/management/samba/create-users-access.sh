#!/bin/bash

set -e

while read -r line; do
  userName=$(echo "${line}" | cut -d: -f1)
  homeDirectory=$(echo "${line}" | cut -d: -f6)
  if echo "${homeDirectory}" | grep '/home' > /dev/null
  then
    if [[ "${userName}" != 'syslog' ]]
    then
      # Check if user already exists
      if sudo pdbedit -L | grep "${userName}"; then
        echo "Samba user already exists."
        exit 0
      fi

      # Ask for password if not provided
      password=$2
      if [[ -z ${password} ]]; then
        read -r -p "Create the Samba password for user \"${userName}\": " password
        if [[ -z ${password} ]]; then
          echo "Password must not be empty." 1>&2
          exit 1
        fi
      fi

      # Create Samba password
      echo "${password}
      ${password}" | sudo smbpasswd -a "${userName}"

      # Create Samba folder
      sambafolder=/home/"${userName}"/data
      if ! test -d "${sambafolder}"; then
        sudo mkdir -p "${sambafolder}"
      fi

      # Add User config
      sambaconfig="
      [${userName}]
      comment = ${userName} files
      path = ${sambafolder}
      browsable = yes
      valid users = %S
      read only = no
      guest ok = no
      create mask = 0664
      directory mask = 0775"
      sambaconfigfile=/etc/samba/smb.conf


      pattern=$(echo "${sambaconfig}" | tr -d '\n')
      content=$(< "${sambaconfigfile}" tr -d '\n')
      if [[ "${content}" != *"${pattern}"* ]]
      then
        echo "${sambaconfig}" | sudo tee -a "${sambaconfigfile}" > /dev/null
      fi

      # Restart Samba
      sudo service smbd restart
    fi
  fi
done </etc/passwd
