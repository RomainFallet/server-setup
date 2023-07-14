#!/bin/bash

bashUserConfigurationPath="${HOME}/.bashrc"
serverSetupHomePath="${HOME}/.server-setup"
serverSetupUserConfigurationPath="${HOME}/.server-setup-configuration"
serverSetupUserConfiguration="export SERVER_SETUP_HOME_PATH=${serverSetupHomePath}
alias ss:self-update='cd ${serverSetupHomePath} && git pull --rebase origin master && cd ${HOME} && bash ${serverSetupHomePath}/scripts/install.sh'
alias ss:recipes:mail-machine='bash ${serverSetupHomePath}/scripts/recipes/mail-machine/index.sh'
alias ss:recipes:application-machine='bash ${serverSetupHomePath}/scripts/recipes/application-machine/index.sh'
alias ss:recipes:daily-backup-machine='bash ${serverSetupHomePath}/scripts/recipes/daily-backup-machine/index.sh'
alias ss:recipes:http-machine='bash ${serverSetupHomePath}/scripts/recipes/http-machine/index.sh'
alias ss:recipes:file-machine='bash ${serverSetupHomePath}/scripts/recipes/file-machine/index.sh'"
serverSetupConfigurationSourcingCommand=". ${serverSetupUserConfigurationPath}"
serverSetupConfigurationPath=/etc/server-setup
serverSetupConfigurationFilePath=/etc/server-setup/main.conf

# Create server-setup user configuration file
echo "${serverSetupUserConfiguration}" | tee "${serverSetupUserConfigurationPath}" > /dev/null

# Add sourcing command to server-setup user configuration file in user's .bashrc file
pattern=$(echo "${serverSetupConfigurationSourcingCommand}" | tr -d '\n')
fileContent=$(< "${HOME}/.bashrc" tr -d '\n')
if [[ "${fileContent}" != *"${pattern}"* ]]
then
  echo "${serverSetupConfigurationSourcingCommand}" | tee -a "${bashUserConfigurationPath}" > /dev/null
fi

# Create server-setup configuration file that will store user inputs
sudo mkdir -p "${serverSetupConfigurationPath}"
sudo touch "${serverSetupConfigurationFilePath}"
sudo chmod -R 700 "${serverSetupConfigurationPath}"
sudo chmod 600 "${serverSetupConfigurationFilePath}"
