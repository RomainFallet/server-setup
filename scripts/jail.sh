#!/bin/bash

# Ask for username if not provided
if [[ -z ${username} ]]; then
  read -r -p "Choose the name of the user you want to put in a jail: " username
  if [[ -z ${username} ]]; then
    echo "User name must not be empty." 1>&2
    exit 1
  fi
fi

# Check if the user exists
USER_ID=$(id -u "${username}" 2> /dev/null)
if [[ -z ${USER_ID} ]]; then
  # Ask for password if not provided
  if [[ -z ${password} ]]; then
    read -r -p "Choose the new user password: " password
    if [[ -z ${password} ]]; then
      echo "Password must not be empty." 1>&2
      exit 1
    fi
  fi

  # Create the user
  echo "Creating user \"${username}\"."
  if ! sudo useradd "${username}" && echo "${username}:${password}"| chpasswd; then
    echo "Unable to create the user." 1>&2
    exit 1
  fi
  echo "User created."
else
  echo "User already exists."
fi

# Create jail directory if not existing
JAIL_DIR=/jails/${username}
echo "Creating jail directory at \"${JAIL_DIR}\"."
if [[ ! -d "${JAIL_DIR}" ]]; then
  if ! sudo mkdir -p "${JAIL_DIR}"; then
    echo "Unable to create the jail directory." 1>&2
    exit 1
  fi
  echo "Jail directory created."
else
  echo "Jail directory already exists."
fi

# Set permissions to jail directory
if ! sudo chown root:root "${JAIL_DIR}" && sudo chmod 0755 "${JAIL_DIR}"; then
  echo "Unable to set appropriate permissions to the jail directory." 1>&2
  exit 1
fi
echo "Set root:root as owner:group and 0755 permissions to jail directory."

# Create home directory if not exising
echo "Creating home directory at \"${JAIL_DIR}/home/${username}\"."
if [[ ! -d "${JAIL_DIR}/home/${username}" ]]; then
  if ! sudo mkdir -p "${JAIL_DIR}/home/${username}"; then
    echo "Unable to create user home directory." 1>&2
    exit 1
  fi
  echo "Home directory created."
else
  echo "Home directory already exists."
fi

# Set permissions to home directory
if ! sudo chown "${username}:${username}" "${JAIL_DIR}/home/${username}" && sudo chmod 0700 "${JAIL_DIR}/home/${username}"; then
  echo "Unable to set appropriate permissions to the home directory." 1>&2
  exit 1
fi
echo "Set ${username}:${username} as owner:group and 0700 permissions to home directory."

# Ask which type of jail we wants for the user
if [[ -z "${commands_list}" ]] && [[ -z "${use_basic_commands}" ]]; then
  read -r -p "Do you want your user to access only basic commands instead of all of them? [N/y]: " use_basic_commands
  use_basic_commands=${use_basic_commands:-n}
  use_basic_commands=$(echo "${use_basic_commands}" | awk '{print tolower($0)}')
fi

# Ask for the commands list we want for the user
if [[ -z "${commands_list}" ]] && [[ "${use_basic_commands}" == 'y' ]]; then
  read -r -p "List basic commands (comma separated) you want to give access to: " commands_list
  if [[ -z "${commands_list}" ]]; then
    echo "You must supply some commands (at least \"bash\" to login)." 1>&2
    exit 1
  fi
fi

# Handle "basic commands access" case
if [[ -n "${commands_list}" ]]; then

  IFS=',' read -ra commands_list <<< "${commands_list}"
  for command in "${commands_list[@]}"
  do
    command_path=$(command -v "${command}")

    # Deps
    for dep_path in $( ldd "${command_path}" | grep -v dynamic | cut -d " " -f 3 | sed 's/://' | sort | uniq )
    do
      if [[ -f "${dep_path}" ]] && [[ ! -f "${JAIL_DIR}${dep_path}" ]]; then
        if ! sudo cp --parents "${dep_path}" "${JAIL_DIR}"; then
          echo "Unable to copy \"${dep_path}\" in the jail directory." 1>&2
          exit 1
        fi
        echo "Dep \"${dep_path}\" copied in the jail direcory."
      else
        echo "Dep \"${dep_path}\" already exists in the jail directory."
      fi
    done

    # Commands
    if [[ -f "${command_path}" ]] && [[ ! -f "${JAIL_DIR}${command_path}" ]]; then

      if ! sudo cp --parents "${command_path}" "${JAIL_DIR}"; then
        echo "Unable to copy \"${command_path}\" in the jail directory." 1>&2
        exit 1
      fi
      echo "Command \"${command_path}\" copied in the jail directory."
    else
      echo "Command \"${command_path}\" already exists in the jail directory."
    fi
  done

  # Others deps
  deps=( /lib64/ld-linux-x86-64.so.2 /lib/ld-linux.so.2 /lib/ld-linux-aarch64.so.1 )
  for dep_path in "${deps[@]}"
  do
    if [[ -f "${dep_path}" ]] && [[ ! -f "${JAIL_DIR}${dep_path}" ]]; then

      if ! sudo cp --parents "${dep_path}" "${JAIL_DIR}"; then
        echo "Unable to copy \"${dep_path}\" in the jail directory." 1>&2
        exit 1
      fi
      echo "Dep \"${dep_path}\" copied in the jail directory."
    else
      echo "Dep \"${dep_path}\" does not exist or already exists in the jail directory."
    fi
  done

# Handle "full commands access" case
else
  # List of directories to mount in the jail
  directories=( /bin /etc /lib /lib64 /usr /dev /var/run /var/lib /tmp /run /proc /opt )

  for directory in "${directories[@]}"
  do
    # Create mount point
    echo "Creating mount point \"${JAIL_DIR}${directory}\"."
    if [[ ! -d "${JAIL_DIR}${directory}" ]]; then

      if ! sudo mkdir -p "${JAIL_DIR}${directory}"; then
        echo "Unable to create the mount point." 1>&2
        exit 1
      fi
      echo "Mount point created."
    else
      echo "Mount point already exists."
    fi

    # Set permissions to mount point
    if ! sudo chown root:root "${JAIL_DIR}${directory}" && sudo chmod 0755 "${JAIL_DIR}${directory}"; then
      echo "Unable to set appropriate permissions to the mount point." 1>&2
      exit 1
    fi
    echo "Set root:root as owner:group and 0755 permissions to the mount point."

    # Determine mount point read-write access
    directories_access=ro
    readwrite_directories=( /tmp )
    for readwrite_directory in "${readwrite_directories[@]}"
    do
      if [[ "${readwrite_directory}" == "${directory}" ]]; then
        directories_access=rw
      fi
    done
    echo "Mount point access is: ${directories_access}."

    # Bind mount
    echo "Mounting \"${directory}\" into \"${JAIL_DIR}${directory}\"."
    is_already_mounted=$(sudo grep "${JAIL_DIR}${directory}" /proc/mounts)

    if [[ -z "${is_already_mounted}" ]]; then
      if ! sudo mount --bind "${directory}" "${JAIL_DIR}${directory}" && sudo mount -o remount,${directories_access},bind "${JAIL_DIR}${directory}"; then
        echo "Unable to mount." 1>&2
        exit 1
      fi
      echo "Mounted."
    else
      echo "Already mounted."
    fi

    # Make the mount permanent
    echo "Making \"${JAIL_DIR}${directory}\" mount permanent in \"/etc/fstab\"."
    is_permanent=$(sudo grep "${JAIL_DIR}${directory}" /etc/fstab)

    if [[ -z "${is_permanent}" ]]; then
      mountconfig="${directory} ${JAIL_DIR}${directory} none ${directories_access},bind 0 0"
      if ! echo "${mountconfig}" | sudo tee -a /etc/fstab > /dev/null; then
        echo "Unable to apply permanently the mount config." 1>&2
        exit 1
      fi
      echo "Mount config applied permanently."
    else
      echo "Mount config already permanent."
    fi
  done
fi

# Set up chroot directory
echo "Adding chroot config for user \"${username}\" in \"/etc/ssh/sshd_config\"."
is_chroot_config_existing=$(sudo grep "Match User ${username}" /etc/ssh/sshd_config)

if [[ -z ${is_chroot_config_existing} ]]; then
  if ! echo "
Match User ${username}
ChrootDirectory ${JAIL_DIR}" | sudo tee -a /etc/ssh/sshd_config > /dev/null; then
    echo "Unable to add chroot config." 1>&2
    exit 1
  fi
  echo "Chroot config added."
else
  echo "Chroot config already exists."
fi

# Set bash as default shell
if ! sudo chsh -s /bin/bash "${username}"; then
  echo "Unable to set the default shell to \"/bin/bash\" for user \"${username}\"." 1>&2
  exit 1
fi
echo "Default shell of user \"${username}\" set to \"/bin/bash\"."

# Restart SSH service
if ! sudo service ssh restart; then
  echo "Unable restart SSH service." 1>&2
  exit 1
fi

echo "Chroot jail is ready. Login with the user or access it with: chroot ${JAIL_DIR}"
