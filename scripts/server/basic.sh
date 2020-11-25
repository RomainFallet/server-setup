#!/bin/bash

# Exit script on error
set -e

### Set up variables

# Ask hostname if not already set
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
sshconfigpath=/etc/ssh/sshd_config
sshconfigbackuppath=/etc/ssh/.sshd_config.backup
if ! test -f "${sshconfigbackuppath}"
then
  sudo cp "${sshconfigpath}" "${sshconfigbackuppath}"
fi

# Disable password authentication
sshpassconfig='PasswordAuthentication no'
sudo sed -i'.tmp' -E "s/#*PasswordAuthentication\s+(\w+)/PasswordAuthentication no/g" "${sshconfigpath}"
if ! sudo grep "^${sshpassconfig}" "${sshconfigpath}" > /dev/null
then
  echo "${sshpassconfig}" | sudo tee -a "${sshconfigpath}" > /dev/null
fi

# Keep alive client connections
sshclientintervalconfig='ClientAliveInterval 120'
sudo sed -i'.tmp' -E "s/#*ClientAliveInterval\s+([0-9]+)/ClientAliveInterval 120/g" "${sshconfigpath}"
if ! sudo grep "^${sshclientintervalconfig}" "${sshconfigpath}" > /dev/null
then
  echo "${sshclientintervalconfig}" | sudo tee -a "${sshconfigpath}" > /dev/null
fi

sshclientcountconfig='ClientAliveCountMax 3'
sudo sed -i'.tmp' -E "s/#*ClientAliveCountMax\s+([0-9]+)/ClientAliveCountMax 3/g" "${sshconfigpath}"
if ! sudo grep "^${sshclientcountconfig}" "${sshconfigpath}" > /dev/null
then
  echo "${sshclientcountconfig}" | sudo tee -a "${sshconfigpath}" > /dev/null
fi

# Remove tmp file
sudo rm -f "${sshconfigpath}".tmp

# Restart SSH
sudo service ssh restart

### Updates

# Install latest updates
sudo apt update && sudo apt dist-upgrade -y

# Make a backup of the config files
periodicconfigpath=/etc/apt/apt.conf.d/10periodic
periodicconfigbackuppath=/etc/apt/apt.conf.d/.10periodic.backup
unattendedupgradeconfigpath=/etc/apt/apt.conf.d/50unattended-upgrades
unattendedupgradeconfigbackuppath=/etc/apt/apt.conf.d/.50unattended-upgrades.backup
if ! test -f "${periodicconfigbackuppath}"
then
  sudo cp "${periodicconfigpath}" "${periodicconfigbackuppath}"
fi
if ! test -f "${unattendedupgradeconfigbackuppath}"
then
  sudo cp "${unattendedupgradeconfigpath}" "${unattendedupgradeconfigbackuppath}"
fi

# Download upgradable packages automatically
echo "APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Download-Upgradeable-Packages \"1\";
APT::Periodic::AutocleanInterval \"7\";" | sudo tee "${periodicconfigpath}" > /dev/null

# Install updates automatically
updateconfig="Unattended-Upgrade::Allowed-Origins {
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
Unattended-Upgrade::Automatic-Reboot-Time \"05:00\";"
echo "${updateconfig}" | sudo tee "${unattendedupgradeconfigpath}" > /dev/null

### Default umask

# Backup config file
umaskconfigpath=/etc/login.defs
umaskconfigbackuppath=/etc/.login.defs.backup
if ! test -f "${umaskconfigbackuppath}"
then
  sudo cp "${umaskconfigpath}" "${umaskconfigbackuppath}"
fi

# Change default system umask
sudo sed -i'.tmp' -E 's/UMASK(\s+)([0-9]+)/UMASK\1002/g' "${umaskconfigpath}"

# Remove tmp file
sudo rm "${umaskconfigpath}".tmp

### Fail2ban

# Install
sudo apt install -y fail2ban

# Add default configuration
fail2banconfig="[DEFAULT]
findtime = 3600
bantime = 86400

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
"
fail2banconfigfile=/etc/fail2ban/jail.local

if ! sudo grep "${fail2banconfig}" "${fail2banconfigfile}" > /dev/null
then
  echo "${fail2banconfig}" | sudo tee -a "${fail2banconfigfile}" > /dev/null
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
