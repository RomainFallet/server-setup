#!/bin/bash

# Exit script on error
set -e

### Create Samba access for all UNIX users

# Loop over each UNIX user
while read -r line; do
  userName=$(echo "${line}" | cut -d: -f1)
  homeDirectory=$(echo "${line}" | cut -d: -f6)

  # Check if it's a valid user
  if echo "${homeDirectory}" | grep '/home' > /dev/null
  then
    if [[ "${userName}" != 'syslog' ]]
    then
      # Check if user already exists
      existingUsers=$(sudo pdbedit -L)
      if echo "${existingUsers}" | grep "${userName}"; then
        echo "Samba user already exists."
        exit 0
      fi

      # Ask for password if not provided
      if [[ -z ${password} ]]; then
        read -u 3 -r -p "Create the Samba password for user \"${userName}\": " password
        if [[ -z ${password} ]]; then
          echo "Password must not be empty." 1>&2
          exit 1
        fi
      fi

      # Create Samba password
      echo "${password}
${password}" | sudo smbpasswd -a "${userName}"

      # Create Samba folder
      sambaFolder=/home/"${userName}"/data
      if ! test -d "${sambaFolder}"; then
        sudo mkdir -p "${sambaFolder}"
      fi

      # Add User config
      sambaConfig="
      [${userName}]
      comment = ${userName} files
      path = ${sambaFolder}
      browsable = yes
      valid users = %S
      read only = no
      guest ok = no
      create mask = 0664
      directory mask = 0775"
      sambaConfigfile=/etc/samba/smb.conf
      pattern=$(echo "${sambaConfig}" | tr -d '\n')
      content=$(< "${sambaConfigfile}" tr -d '\n')
      if [[ "${content}" != *"${pattern}"* ]]
      then
        echo "${sambaConfig}" | sudo tee -a "${sambaConfigfile}" > /dev/null
      fi

      # Restart Samba
      sudo service smbd restart
    fi
  fi
done 3<&0 </etc/passwd
