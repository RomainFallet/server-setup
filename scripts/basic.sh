#!/bin/bash

# Exit script on error
set -e

### Ask informations

# Ask hostname if not already set
hostname=${1}
if [[ -z "${hostname}" ]]
then
  read -r -p "Enter your hostname (it must be a domain name pointing to this machine IP address): " hostname
fi

### Timezone

# Change timezone
sudo timedatectl set-timezone Europe/Paris

### Hostname

# Change hostname
sudo hostnamectl set-hostname "${hostname}"

### SSH

# Backup config file
sshConfigPath=/etc/ssh/sshd_config
sshConfigBackupPath=/etc/ssh/.sshd_config.backup
if ! test -f "${sshConfigBackupPath}"
then
  sudo cp "${sshConfigPath}" "${sshConfigBackupPath}"
fi

# Disable password authentication
sshPasswordConfig='PasswordAuthentication no'
sudo sed -i'.tmp' -E "s/#*PasswordAuthentication\s+(\w+)/PasswordAuthentication no/g" "${sshConfigPath}"
if ! sudo grep "^${sshPasswordConfig}" "${sshConfigPath}" > /dev/null
then
  echo "${sshPasswordConfig}" | sudo tee -a "${sshConfigPath}" > /dev/null
fi

# Keep alive client connections
sshClientIntervalconfig='ClientAliveInterval 60'
sudo sed -i'.tmp' -E "s/#*ClientAliveInterval\s+([0-9]+)/ClientAliveInterval 60/g" "${sshConfigPath}"
if ! sudo grep "^${sshClientIntervalconfig}" "${sshConfigPath}" > /dev/null
then
  echo "${sshClientIntervalconfig}" | sudo tee -a "${sshConfigPath}" > /dev/null
fi

sshClientCountConfig='ClientAliveCountMax 10'
sudo sed -i'.tmp' -E "s/#*ClientAliveCountMax\s+([0-9]+)/ClientAliveCountMax 10/g" "${sshConfigPath}"
if ! sudo grep "^${sshClientCountConfig}" "${sshConfigPath}" > /dev/null
then
  echo "${sshClientCountConfig}" | sudo tee -a "${sshConfigPath}" > /dev/null
fi

# Remove tmp file
sudo rm -f "${sshConfigPath}".tmp

# Restart SSH
sudo service ssh restart

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

### Default umask

# Backup config file
# umaskConfigPath=/etc/login.defs
# umaskConfigBackupPath=/etc/.login.defs.backup
# if ! test -f "${umaskConfigBackupPath}"
# then
#   sudo cp "${umaskConfigPath}" "${umaskConfigBackupPath}"
# fi

# # Change default system umask
# sudo sed -i'.tmp' -E 's/UMASK(\s+)([0-9]+)/UMASK\1002/g' "${umaskConfigPath}"

# # Remove tmp file
# sudo rm "${umaskConfigPath}".tmp

### Fail2ban

# Install
sudo apt install -y fail2ban

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

# Display Fail2ban version
fail2ban-client -V

### Firewall

# Allow SSH connections
sudo ufw allow ssh

# Enable Firewall
echo 'y' | sudo ufw enable

# Show Firewall status
sudo ufw status
