#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/variables/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/network/index.sh"

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

function SetUpUnattentedUpgrades () {
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

function SetUpIpv6 () {
  AskIfNotSet configureIpv6 'Configure IPv6? (y/n)' 'y'
  if [[ "${configureIpv6:?}" == 'y' ]]; then
    AskIfNotSet ipv6Address "Enter your IPv6 address (eg. 2001:XXXX:XXX:XXXX::XXXX)"
    AskIfNotSet ipv6Gateway "Enter your IPv6 gateway (eg. 2001:XXXX:XXX:XXXX::1)"
    ipv4ConfigurationPath=/etc/netplan/50-cloud-init.yaml
    ipv6ConfigurationPath=/etc/netplan/51-cloud-init-ipv6.yaml
    # shellcheck disable=SC2312
    ethernetConnectionName=$(sudo ls /sys/class/net | sort -V | awk 'FNR == 1 {print}')
    ethernetConnectionMacAddress=$(cat /sys/class/net/"${ethernetConnectionName}"/address)
    ipv4Configuration="network:
      version: 2
      ethernets:
          ${ethernetConnectionName}:
              dhcp4: true
              match:
                  macaddress: ${ethernetConnectionMacAddress}
              mtu: 1500
              set-name: ${ethernetConnectionName}"
    ipv4ConfigurationPath=/etc/netplan/50-cloud-init.yaml
    SetFileContent "${ipv4Configuration}" "${ipv4ConfigurationPath}"
    ipv6Configuration="network:
      version: 2
      ethernets:
          ${ethernetConnectionName}:
              dhcp6: false
              mtu: 1500
              match:
                  macaddress: ${ethernetConnectionMacAddress}
              set-name: ${ethernetConnectionName}
              addresses:
                  - ${ipv6Address:?}/128
              routes:
                  - to: default
                    via: ${ipv6Gateway:?}
                  - to: ${ipv6Gateway:?}
                    scope: link"
    SetFileContent "${ipv6Configuration}" "${ipv6ConfigurationPath}"
    SetFileContent "network: {config: disabled}" /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
    EnableNetworkConfiguration
  fi
}
