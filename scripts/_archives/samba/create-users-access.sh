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
      # Ask for password
      read -u 3 -r -p "Create the Samba password for user \"${userName}\": " password
      if [[ -z ${password} ]]; then
        echo "Password must not be empty." 1>&2
        exit 1
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
guest ok = no"
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
