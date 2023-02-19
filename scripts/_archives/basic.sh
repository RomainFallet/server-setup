#!/bin/bash

function SetTimeZone () {
  sudo timedatectl set-timezone Europe/Paris
}

function SetHostName () {
  hostname="${1}"
  sudo hostnamectl set-hostname "${hostname}"
}

function CopyFileIfNotExisting () {
  filePath="${1}"
  destinationPath="${2}"
  if ! test -f "${destinationPath}"
  then
    sudo cp "${filePath}" "${destinationPath}"
  fi
}

function AppendTextInFileIfNotFound () {
  text="${1}"
  filePath="${2}"
  pattern=$(echo "${text}" | tr -d '\n')
  fileContent=$(< "${filePath}" tr -d '\n')
  if [[ "${fileContent}" != *"${pattern}"* ]]
  then
    echo "${text}" | sudo tee -a "${filePath}" > /dev/null
  fi
}

function ReplaceTextInFile () {
  regexPattern="${1}"
  replacementText="${2}"
  filePath="${3}"
  sudo sed -i'.tmp' -E "s|${regexPattern}|${replacementText}|g" "${filePath}"
  sudo rm -f "${filePath}".tmp
}

function DisableSshPasswordAuthentication () {
  passwordConfiguration='PasswordAuthentication no'
  ReplaceTextInFile '#*PasswordAuthentication\s+\w+' "${passwordConfiguration}" /etc/ssh/sshd_config
  AppendTextInFileIfNotFound "${passwordConfiguration}" /etc/ssh/sshd_config
}

function ConfigureSshKeepAlive () {
  clientAliveIntervalConfiguration='ClientAliveInterval 60'
  ReplaceTextInFile '#*ClientAliveInterval\s+[0-9]+' "${clientAliveIntervalConfiguration}" /etc/ssh/sshd_config
  AppendTextInFileIfNotFound "${clientAliveIntervalConfiguration}" /etc/ssh/sshd_config

  clientAliveCountConfiguration='ClientAliveCountMax 10'
  ReplaceTextInFile '#*ClientAliveCountMax\s+[0-9]+' "${clientAliveCountConfiguration}" /etc/ssh/sshd_config
  AppendTextInFileIfNotFound "${clientAliveCountConfiguration}" /etc/ssh/sshd_config
}

function RestartSsh () {
  sudo service ssh restart
}

function WhiteListSshInFirewall () {
  sudo ufw allow ssh
}

function BackupSshConfigFile () {
  CopyFileIfNotExisting /etc/ssh/sshd_config /etc/ssh/.sshd_config.backup
}

function ConfigureSsh () {
  BackupSshConfigFile
  DisableSshPasswordAuthentication
  ConfigureSshKeepAlive
  WhiteListSshInFirewall
  RestartSsh
}

# Exit script on error
set -e

### Ask informations

# Ask hostname if not already set
hostname=${1}
if [[ -z "${hostname}" ]]
then
  read -r -p "Enter your hostname: " hostname
fi

SetTimeZone
SetHostName "${hostname}"
ConfigureSsh


### Updates

# Install latest updates
sudo apt update && sudo apt dist-upgrade -y

# Make a backup of the config files
periodicConfigPath=/etc/apt/apt.conf.d/10periodic
periodicConfigBackupPath=/etc/apt/apt.conf.d/.10periodic.backup
unattendedUpgradeConfigPath=/etc/apt/apt.conf.d/50unattended-upgrades
unattendedUpgradeConfigBackupPath=/etc/apt/apt.conf.d/.50unattended-upgrades.backup
if ! test -f "${periodicConfigBackupPath}"
then
  sudo cp "${periodicConfigPath}" "${periodicConfigBackupPath}"
fi
if ! test -f "${unattendedUpgradeConfigBackupPath}"
then
  sudo cp "${unattendedUpgradeConfigPath}" "${unattendedUpgradeConfigBackupPath}"
fi

# Download upgradable packages automatically
echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Download-Upgradeable-Packages \"1\";
APT::Periodic::AutocleanInterval \"7\";" | sudo tee "${periodicConfigPath}" > /dev/null

# Install updates automatically
echo "Unattended-Upgrade::Allowed-Origins {
  \"\${distro_id}:\${distro_codename}\";
  \"\${distro_id}:\${distro_codename}-security\";
  \"\${distro_id}ESMApps:\${distro_codename}-apps-security\";
  \"\${distro_id}ESM:\${distro_codename}-infra-security\";
  \"\${distro_id}:\${distro_codename}-updates\";
};
Unattended-Upgrade::DevRelease \"false\";
Unattended-Upgrade::Remove-Unused-Kernel-Packages \"true\";
Unattended-Upgrade::Remove-Unused-Dependencies \"true\";
Unattended-Upgrade::Automatic-Reboot \"true\";
Unattended-Upgrade::Automatic-Reboot-Time \"05:00\";" | sudo tee "${unattendedUpgradeConfigPath}" > /dev/null

### Fail2ban

# Install
dpkg -s fail2ban &> /dev/null || sudo apt install -y fail2ban

# Create config file
fail2banConfigFile=/etc/fail2ban/jail.local
if ! test -f "${fail2banConfigFile}"
then
  sudo touch /etc/fail2ban/jail.local
fi

# Add default configuration
fail2banConfig="[DEFAULT]
findtime = 3600
bantime = 86400

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3"
pattern=$(echo "${fail2banConfig}" | tr -d '\n')
content=$(< "${fail2banConfigFile}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${fail2banConfig}" | sudo tee -a "${fail2banConfigFile}" > /dev/null
fi

# Restart Fail2ban
sudo service fail2ban restart

### Firewall

# Allow SSH connections
sudo ufw allow ssh

# Enable Firewall
echo 'y' | sudo ufw enable
