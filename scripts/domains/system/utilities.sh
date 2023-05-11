#!/bin/bash

# shellcheck source=../../shared/files/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source=../../shared/variables/index.sh
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"

function SetTimeZone () {
  timeZone="${1}"
  AskIfNotSet timeZone "Enter your time zone" 'Europe/Paris'
  sudo timedatectl set-timezone "${timeZone}"
}

function SetHostName () {
  hostName="${1}"
  AskIfNotSet hostName "Enter your hostname (eg. example.com)"
  sudo hostnamectl set-hostname "${hostName}"
}

function ConfigureAutomaticUpdates () {
  periocConfigPath=/etc/apt/apt.conf.d/10periodic
  unattendedUpgradeConfigPath=/etc/apt/apt.conf.d/50unattended-upgrades
  periodicConfig="APT::Periodic::Update-Package-Lists \"1\";
APT::Periodic::Download-Upgradeable-Packages \"1\";
APT::Periodic::AutocleanInterval \"7\";"
  unattendedUpgradeConfig="Unattended-Upgrade::Allowed-Origins {
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
  BackupFile "${periocConfigPath}"
  BackupFile "${unattendedUpgradeConfigPath}"
  SetFileContent "${periodicConfig}" "${periocConfigPath}"
  SetFileContent "${unattendedUpgradeConfig}" "${unattendedUpgradeConfigPath}"
}
