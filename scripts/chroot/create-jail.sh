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
userId=$(id -u "${username}")

# Create jail directory
jailPath=/jails/${username}
sudo mkdir -p "${jailPath}"

# Create home directory
sudo mkdir -p "${jailPath}/home/${username}"
sudo chown "${username}:${username}" "${jailPath}/home/${username}"

# Create dev
sudo mkdir -p "${jailPath}"/dev
sudo rm -f "${jailPath}"/dev/null
sudo mknod -m 666 "${jailPath}"/dev/null c 1 3

# Create etc
sudo mkdir -p "${jailPath}"/etc
echo "${username}:x:${userId}:${userId}::/home/${username}:/bin/bash
" | sudo tee "${jailPath}"/etc/passwd > /dev/null
echo "${username}:x:${userId}:
" | sudo tee "${jailPath}"/etc/group > /dev/null
sudo cp /etc/nsswitch.conf "${jailPath}"/etc/nsswitch.conf
sudo cp -r /etc/skel "${jailPath}"/etc

# Commands list to set up in the chroot jail
commandsList="/bin/bash,/bin/ls,/bin/cp,/bin/mv,/bin/rm,/bin/touch,/bin/mkdir,/bin/rmdir,/usr/bin/vi,/usr/bin/rsync,/usr/bin/scp"
IFS=',' read -ra commandsList <<< "${commandsList}"
for commandPath in "${commandsList[@]}"
do
  # Copy deps
  for depPath in $( (ldd "${commandPath}" || true) | (grep -v dynamic || true) | (cut -d " " -f 3 || true) | (sed 's/://' || true) | (sort || true) | uniq )
  do
    if [[ -f "${depPath}" ]] && [[ ! -f "${jailPath}${depPath}" ]]; then
      sudo cp --parents "${depPath}" "${jailPath}"
    fi
  done

  # Copy commands
  if [[ -f "${commandPath}" ]] && [[ ! -f "${jailPath}${commandPath}" ]]; then
    sudo cp --parents "${commandPath}" "${jailPath}"
  fi
done

# Copy others deps
deps=( /lib64/ld-linux-x86-64.so.2 /lib/ld-linux.so.2 /lib/ld-linux-aarch64.so.1)
for depPath in "${deps[@]}"
do
  if [[ -f "${depPath}" ]] && [[ ! -f "${jailPath}${depPath}" ]]; then
    sudo cp --parents "${depPath}" "${jailPath}"
  fi
done

# Set up chroot directory
sshConfig="
Match User ${username}
  ChrootDirectory ${jailPath}
  AllowTcpForwarding no
  X11Forwarding no
"
sshConfigPath=/etc/ssh/sshd_config
pattern=$(echo "${sshConfig}" | tr -d '\n')
content=$(< "${sshConfigPath}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${sshConfig}" | sudo tee -a "${sshConfigPath}" > /dev/null
fi

# Enable SFTP
sshSftpConfig='Subsystem sftp internal-sftp'
sudo sed -i'.tmp' -E "s/#*Subsystem\s+sftp\s+(.+)/${sshSftpConfig}/g" "${sshConfigPath}"
sudo rm -f "${sshConfigPath}".tmp
if ! sudo grep "^${sshSftpConfig}" "${sshConfigPath}" > /dev/null
then
  echo "${sshSftpConfig}" | sudo tee -a "${sshConfigPath}" > /dev/null
fi

# Set bash as default shell
sudo chsh -s /bin/bash "${username}"

# Restart SSH service
sudo service ssh restart
