#!/bin/bash

# Exit script on error
set -e

### Create chroot jail

# Ask for username if not provided
username=${1}
if [[ -z ${username} ]]; then
  read -r -p "Choose the name of the user you want to put in a jail: " username
  if [[ -z ${username} ]]; then
    echo "User name must not be empty." 1>&2
    exit 1
  fi
fi

# Check if the user exists
userId=$(id -u "${username}" 2> /dev/null)
if [[ -z ${userId} ]]; then
  # Ask for password if not provided
  password=${2}
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
jailPath=/jails/${username}
echo "Creating jail directory at \"${jailPath}\"."
if [[ ! -d "${jailPath}" ]]; then
  if ! sudo mkdir -p "${jailPath}"; then
    echo "Unable to create the jail directory." 1>&2
    exit 1
  fi
  echo "Jail directory created."
else
  echo "Jail directory already exists."
fi

# Set permissions to jail directory
if ! sudo chown root:root "${jailPath}" && sudo chmod 0755 "${jailPath}"; then
  echo "Unable to set appropriate permissions to the jail directory." 1>&2
  exit 1
fi
echo "Set root:root as owner:group and 0755 permissions to jail directory."

# Create home directory if not exising
echo "Creating home directory at \"${jailPath}/home/${username}\"."
if [[ ! -d "${jailPath}/home/${username}" ]]; then
  if ! sudo mkdir -p "${jailPath}/home/${username}"; then
    echo "Unable to create user home directory." 1>&2
    exit 1
  fi
  echo "Home directory created."
else
  echo "Home directory already exists."
fi

# Set permissions to home directory
if ! sudo chown "${username}:${username}" "${jailPath}/home/${username}" && sudo chmod 0700 "${jailPath}/home/${username}"; then
  echo "Unable to set appropriate permissions to the home directory." 1>&2
  exit 1
fi
echo "Set ${username}:${username} as owner:group and 0700 permissions to home directory."

# Ask which type of jail we wants for the user
if [[ -z "${commandsList}" ]] && [[ -z "${useBasicCommands}" ]]; then
  read -r -p "Do you want your user to access only basic commands instead of all of them? [N/y]: " useBasicCommands
  useBasicCommands=${useBasicCommands:-n}
  useBasicCommands=$(echo "${useBasicCommands}" | awk '{print tolower($0)}')
fi

# Ask for the commands list we want for the user
if [[ -z "${commandsList}" ]] && [[ "${useBasicCommands}" == 'y' ]]; then
  read -r -p "List basic commands (comma separated) you want to give access to: " commandsList
  if [[ -z "${commandsList}" ]]; then
    echo "You must supply some commands (at least \"bash\" to login)." 1>&2
    exit 1
  fi
fi

# Handle "basic commands access" case
if [[ -n "${commandsList}" ]]; then

  IFS=',' read -ra commandsList <<< "${commandsList}"
  for command in "${commandsList[@]}"
  do
    commandPath=$(command -v "${command}")

    # Deps

    for depPath in $( (ldd "${commandPath}" || true) | (grep -v dynamic || true) | (cut -d " " -f 3 || true) | (sed 's/://' || true) | (sort || true) | uniq )
    do
      if [[ -f "${depPath}" ]] && [[ ! -f "${jailPath}${depPath}" ]]; then
        if ! sudo cp --parents "${depPath}" "${jailPath}"; then
          echo "Unable to copy \"${depPath}\" in the jail directory." 1>&2
          exit 1
        fi
        echo "Dep \"${depPath}\" copied in the jail direcory."
      else
        echo "Dep \"${depPath}\" already exists in the jail directory."
      fi
    done

    # Commands
    if [[ -f "${commandPath}" ]] && [[ ! -f "${jailPath}${commandPath}" ]]; then

      if ! sudo cp --parents "${commandPath}" "${jailPath}"; then
        echo "Unable to copy \"${commandPath}\" in the jail directory." 1>&2
        exit 1
      fi
      echo "Command \"${commandPath}\" copied in the jail directory."
    else
      echo "Command \"${commandPath}\" already exists in the jail directory."
    fi
  done

  # Others deps
  deps=( /lib64/ld-linux-x86-64.so.2 /lib/ld-linux.so.2 /lib/ld-linux-aarch64.so.1 )
  for depPath in "${deps[@]}"
  do
    if [[ -f "${depPath}" ]] && [[ ! -f "${jailPath}${depPath}" ]]; then

      if ! sudo cp --parents "${depPath}" "${jailPath}"; then
        echo "Unable to copy \"${depPath}\" in the jail directory." 1>&2
        exit 1
      fi
      echo "Dep \"${depPath}\" copied in the jail directory."
    else
      echo "Dep \"${depPath}\" does not exist or already exists in the jail directory."
    fi
  done

# Handle "full commands access" case
else
  # List of directories to mount in the jail
  directories=( /bin /etc /lib /lib64 /usr /dev /var/run /var/lib /tmp /run /proc /opt )

  for directory in "${directories[@]}"
  do
    # Create mount point
    echo "Creating mount point \"${jailPath}${directory}\"."
    if [[ ! -d "${jailPath}${directory}" ]]; then

      if ! sudo mkdir -p "${jailPath}${directory}"; then
        echo "Unable to create the mount point." 1>&2
        exit 1
      fi
      echo "Mount point created."
    else
      echo "Mount point already exists."
    fi

    # Set permissions to mount point
    if ! sudo chown root:root "${jailPath}${directory}" && sudo chmod 0755 "${jailPath}${directory}"; then
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
    echo "Mounting \"${directory}\" into \"${jailPath}${directory}\"."
    is_already_mounted=$(sudo grep "${jailPath}${directory}" /proc/mounts)

    if [[ -z "${is_already_mounted}" ]]; then
      if ! sudo mount --bind "${directory}" "${jailPath}${directory}" && sudo mount -o remount,${directories_access},bind "${jailPath}${directory}"; then
        echo "Unable to mount." 1>&2
        exit 1
      fi
      echo "Mounted."
    else
      echo "Already mounted."
    fi

    # Make the mount permanent
    echo "Making \"${jailPath}${directory}\" mount permanent in \"/etc/fstab\"."
    is_permanent=$(sudo grep "${jailPath}${directory}" /etc/fstab)

    if [[ -z "${is_permanent}" ]]; then
      mountconfig="${directory} ${jailPath}${directory} none ${directories_access},bind 0 0"
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
ChrootDirectory ${jailPath}" | sudo tee -a /etc/ssh/sshd_config > /dev/null; then
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

echo "Chroot jail is ready. Login with the user or access it with: chroot ${jailPath}"
