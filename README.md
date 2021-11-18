# Server setup instructions

The purpose of this repository is to provide instructions
to set up a machine with file sharing and web hosting capabilities.

The goal is to provide an opinionated environment that just work for commons scenarios.

## Table of contents

- [Prerequisites](#prerequisites)
  - [Create a user account with sudo privileges](#create-a-user-account-with-sudo-privileges)
  - [Configure an SSH key](#configure-an-ssh-key)
  - [Point your domain names to your machine IP address](#point-your-domain-names-to-your-machine-ip-address)
- [Installation](#installation)
- [Server setup](#server-setup)
  - [Basic](#basic)
  - [Web server](#web-server)
- [Environment setup](#environment-setup)
  - [PHP](#php)
- [Database setup](#database-setup)
  - [MariaDB](#mariadb)
  - [PostgreSQL](#postgresql)
- [Management](#management)
  - [Nginx - Cerbot](#nginx---cerbot)
    - [Get TLS certificate](#get-tls-certificate)
    - [Set up an app with a domain name](#set-up-an-app-with-a-domain-name)
    - [Set up an app with a local port](#set-up-an-app-with-a-local-port)
- [Apps](#apps)
  - [Mailinabox](#mailinabox)
  - [Listmonk](#listmonk)
- [Recipes](#recipes)
  - [Mail server](#mail-server)
  - [Files server](#files-server)

## Prerequisites

### Create a user account with sudo privileges

[Back to top ↑](#table-of-contents)

By default, Ubuntu comes preinstalled with a non-root sudo user named "ubuntu".
The "root" user exists but is not accessible through SSH with a password.
This is how you are supposed to use your machine, because
part of the power inherent with the root account is the
ability to make very destructive changes, even by accident.

But you will probably want something more meaningful
than "ubuntu" as a username, so you can rename it by
enabling temporary access to the "root" account
(because you can't rename the user you currently logged in).

<!-- markdownlint-disable MD013 -->
```bash
# Login to your machine's "ubuntu" account
ssh ubuntu@<ipAddress>

# Define a password for the root account
sudo passwd root

# Allow root login with password through SSH
sudo sed -i'.backup' -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config

# Restart SSH
sudo service ssh restart

# Disconnect from your machine
exit

# Login to your machine's root account
ssh root@<ipAddress>

# Rename user
usermod -l <newUserName> ubuntu

# Rename user group
groupmod -n <newUserName> ubuntu

# Rename home directory
usermod -d /home/<newUserName> -m <newUserName>

# Change password
passwd <newUserName>

# Disable root password
passwd -l root

# Restore initial SSH config
mv /etc/ssh/sshd_config.backup /etc/ssh/sshd_config

# Restart SSH
service ssh restart

# Disconnect from your machine
exit
```
<!-- markdownlint-enable MD013 -->

_SSH client is enabled by default on Windows since the 2018 April update (1804).
Download the update if you have an error when using SSH command in PowerShell._

### Configure an SSH key

[Back to top ↑](#table-of-contents)

Before going any further, you need to generate an SSH key.

```bash
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
```

Then add it to your server by using:

<!-- markdownlint-disable MD013 -->
```bash
ssh <yourUserName>@<yourIpAddress> "echo '$(cat ~/.ssh/id_rsa.pub)' | tee -a ~/.ssh/authorized_keys > /dev/null"
```
<!-- markdownlint-enable MD013 -->

You can also add it to the root account:

<!-- markdownlint-disable MD013 -->
```bash
ssh -t <yourUserName>@<yourIpAddress> "echo '$(cat ~/.ssh/id_rsa.pub)' | sudo tee -a /root/.ssh/authorized_keys > /dev/null"
```
<!-- markdownlint-enable MD013 -->

### Point your domain names to your machine IP address

[Back to top ↑](#table-of-contents)

Before continuing, your machine needs to have a dedicated domain name
that will be its hostname.

You also need to point your app domain names to your machine IP address
if you want to host an app for them. See with your domain name registrar
to set up A (IPV4) or AAAA (IPV6) records to perform this operation.

A minimal DNS zone typically looks like this:

![minimal-dns-zone](https://user-images.githubusercontent.com/6952638/84637979-ae703b00-aef6-11ea-8343-0f2036609a6c.png)

For example, after that, you will be able to login with:

```bash
ssh <username>@mymachine.example.com
```

Instead of:

```bash
ssh <username>@50.70.150.30
```

## Installation

[Back to top ↑](#table-of-contents)

Login to your machine's sudo user and run the following commands.

```bash
git clone https://github.com/RomainFallet/server-setup ~/server-setup

cd ~/server-setup
```

## Server setup

### Basic

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/server/basic.sh
```

This will configure the timezone, the hostname, SSH, automatic updates,
Fail2Ban and the firewall.

### File server

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/server/file-server/samba/install.sh
```

This will install and configure Samba.

### Web server

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/server/web-server/nginx/install.sh
```

This will install and configure Nginx and Certbot.

## Environment setup

### PHP

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/server/environments/php/7.4/install.sh
```

## Database setup

### PostgreSQL

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/server/databases/postgresql/14/install.sh
```

### MariaDB

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/server/databases/mariadb/10.5/install.sh
```

## Management

### Samba

#### Create users access

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/samba/create-users-access.sh
```

#### Create shared access

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/samba/create-shared-access.sh
```

### Nginx - Cerbot

#### Get TLS certificate

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/nginx-certbot/get-tls-certificate.sh
```

#### Set up an app with a domain name

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/nginx-certbot/set-up-domain-name-app.sh
```

#### Set up an app with a local port

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/nginx-certbot/set-up-local-port-app.sh
```

### Disks

#### Set up a data disk

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/disks/set-up-data-disk.sh
```

### Rsync

#### Set up an hourly backup

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/rsync/set-up-hourly-backup.sh
```

#### Restore backup

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/management/rsync/restore-backup.sh
```

## Apps

### Mailinabox

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/apps/mailinabox/0.53a/install.sh
```

### Listmonk

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/apps/listmonk/2.0.0/install.sh
```

## Recipes

### Mail server

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/recipes/mail-server.sh
```

### Files server

[Back to top ↑](#table-of-contents)

```bash
bash ./scripts/recipes/files-server.sh
```
