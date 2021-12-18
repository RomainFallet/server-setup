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

# Create user if not existing
id -u "${userName}" > /dev/null || sudo useradd --create-home --shell /bin/bash "${userName}"
