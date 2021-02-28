#!/bin/bash

# Exit script on error
set -e

### Samba file server

# Install
sudo apt install -y samba

# Allow Samba connections
sudo ufw allow samba
