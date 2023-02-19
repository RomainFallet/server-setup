#!/bin/bash

# Exit script on error
set -e

### Create a new UNIX user

# Ask user name
userName=${1}
if [[ -z "${userName}" ]]
then
  read -r -p "Enter the name of the new user: " userName
fi

# Ask public key
sshPublicKey=${2}
if [[ -z "${sshPublicKey}" ]]
then
  read -r -p "Enter the public key of the machine that the user will use to log in: " sshPublicKey
fi


# Create user if not existing
id -u "${userName}" &> /dev/null || sudo useradd --create-home --shell /bin/bash "${userName}"

# Create .ssh directory
sudo mkdir -p /home/"${userName}"/.ssh
sudo chown "${userName}":"${userName}" /home/"${userName}"/.ssh
sudo chmod 0700 ~/.ssh

# Create auhorized keys
echo "
${sshPublicKey}" | sudo tee /home/"${userName}"/.ssh/authorized_keys > /dev/null
sudo chown "${userName}":"${userName}" /home/"${userName}"/.ssh/authorized_keys
sudo chmod 0600 /home/"${userName}"/.ssh/authorized_keys

