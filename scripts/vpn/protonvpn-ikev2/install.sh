#!/bin/bash

# Exit script on error
set -e

### ProtonVPN IKEv2

# Ask protonvpn username
username=${1}
if [[ -z "${username}" ]]
then
  read -r -p "Enter your ProtonVPN IKEv2 username: " username
fi

# Ask protonvpn password
password=${2}
if [[ -z "${password}" ]]
then
  read -r -p "Enter your ProtonVPN IKEv2 password: " password
fi

# Install
dpkg -s strongswan &> /dev/null || sudo apt install -y strongswan
dpkg -s libstrongswan-extra-plugins &> /dev/null || sudo apt install -y libstrongswan-extra-plugins
dpkg -s libcharon-extra-plugins &> /dev/null || sudo apt install -y libcharon-extra-plugins

# Download ProtonVPN certificate
if ! test -f /etc/ipsec.d/cacerts/protonvpn.der; then
  wget https://protonvpn.com/download/ProtonVPN_ike_root.der -O /tmp/protonvpn.der
  sudo mv /tmp/protonvpn.der /etc/ipsec.d/cacerts/
fi

echo "# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
  # strictcrlpolicy=yes
  # uniqueids = no

conn protonvpn
  left=%defaultroute
  leftsourceip=%config
  leftauth=eap-mschapv2
  eap_identity=${username}
  right=fr.protonvpn.com
  rightsubnet=0.0.0.0/0
  rightauth=pubkey
  rightid=%fr.protonvpn.com
  rightca=/etc/ipsec.d/cacerts/protonvpn.der
  keyexchange=ikev2
  type=tunnel
  auto=add
" | sudo tee /etc/ipsec.conf > /dev/null

echo "# This file holds shared secrets or RSA private keys for authentication.

# RSA private key for this host, authenticating it to any other host
# which knows the public part.
${username} : ${password}
" | sudo tee /etc/ipsec.secrets > /dev/null

# Create service file
echo "[Unit]
Description=ProtonVPN IKEv2 service
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/ipsec up protonvpn
User=root
Group=root

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/protonvpn-ikev2.service > /dev/null

# Reload service files
sudo systemctl daemon-reload

# Enable service on startup
sudo systemctl enable protonvpn-ikev2.service

# Start service now
sudo systemctl restart protonvpn-ikev2.service
