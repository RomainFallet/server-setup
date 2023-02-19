#!/bin/bash

# Exit script on error
set -e

### Mailinabox

# Clone repository
if ! test -d ~/mailinabox
then
  git clone https://github.com/mail-in-a-box/mailinabox  ~/mailinabox
fi

# Select version
cd ~/mailinabox
git fetch && git checkout v60.1

# Install
sudo ./setup/start.sh
cd ~/

# Backup Postfix config file
postfixConfigPath=/etc/postfix/main.cf
postfixConfigBackupPath=/etc/postfix/.main.cf.backup
if ! test -f "${postfixConfigBackupPath}"
then
  sudo cp "${postfixConfigPath}" "${postfixConfigBackupPath}"
fi

# Disable IPV6 sending
postfixInetConfig='inet_protocols = ipv4'
sudo sed -i'.tmp' -E "s/#*inet_protocols =\s+(\w+)/inet_protocols = ipv4/g" "${postfixConfigPath}"
if ! sudo grep "^${postfixInetConfig}" "${postfixConfigPath}" > /dev/null
then
  echo "${postfixInetConfig}" | sudo tee -a "${postfixConfigPath}" > /dev/null
fi

# Restart Postfix
sudo systemctl restart postfix
