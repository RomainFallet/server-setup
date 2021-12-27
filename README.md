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
- [Update](#update)
- [Recipes](#recipes)
  - [Web machine](#web-machine)
  - [NodeJS app](#nodejs-app)
  - [File machine](#file-machine)
  - [Mail machine](#mail-machine)
  - [Backup machine](#backup-machine)
- [Server setup](#server-setup)
  - [Basic](#basic)
  - [Web server](#web-server)
  - [File server](#file-server)
  - [VPN](#vpn)
  - [Torrent client](#torrent-client)
- [Environment setup](#environment-setup)
  - [NodeJS](#nodejs)
- [Database setup](#database-setup)
  - [PostgreSQL setup](#postgresql-setup)
- [Management](#management)
  - [Nginx - Cerbot](#nginx---cerbot)
    - [Get TLS certificate](#get-tls-certificate)
    - [Set up an app with a domain name](#set-up-an-app-with-a-domain-name)
    - [Set up daily dump (Nginx and Letsencrypt)](#set-up-daily-dump-nginx-and-letsencrypt)
    - [Restore dump (Nginx and Letsencrypt)](#restore-dump-nginx-and-letsencrypt)
  - [PostgreSQL](#postgresql)
    - [Set up daily dump (PostgreSQL)](#set-up-daily-dump-postgresql)
    - [Restore dump (PostgreSQL)](#restore-dump-PostgreSQL)
  - [Users](#users)
    - [Create a new user](#create-a-new-user)
  - [Chroot](#chroot)
    - [Create a chroot jail](#create-a-chroot-jail)
  - [Systemd](#systemd)
    - [Create a startup service](#create-a-startup-service)
    - [Create a startup service with autorestart watcher](#create-a-startup-service-with-autorestart-watcher)
  - [Bindfs](#bindfs)
    - [Create a permanent readonly bind mount](#create-permanent-readonly-bind-mount)
  - [Disks](#disks)
    - [Set up a data disk](#set-up-a-data-disk)
    - [Set up daily SMART test](#set-up-daily-smart-test)
    - [Set up weekly SMART test](#set-up-weekly-smart-test)
  - [Rsync](#rsync)
    - [Set up an daily backup](#set-up-an-daily-backup)
    - [Restore backup](#restore-backup)
  - [Samba](#samba)
    - [Create users access](#create-users-access)
    - [Create shared access](#create-shared-access)
- [Apps](#apps)
  - [Mailinabox](#mailinabox)

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
# Clone server-setup scripts in home directory
git clone https://github.com/RomainFallet/server-setup ~/.server-setup

# Install commands in ~/.bash_aliases
bash ~/.server-setup/scripts/install.sh && . ~/.bash_aliases
```

## Update

[Back to top ↑](#table-of-contents)

```bash
# Update server-setup itself
ss:update
```

## Recipes

### Web machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:web-machine
```

### NodeJS app

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:nodejs-app
```

### Mail machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:mail-machine
```

### File machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:file-machine
```

### Backup machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:backup-machine
```

## Server setup

### Basic

[Back to top ↑](#table-of-contents)

```bash
ss:basic
```

This will configure the timezone, the hostname, SSH, automatic updates,
Fail2Ban and the firewall.

### Web server

[Back to top ↑](#table-of-contents)

```bash
ss:web-server:nginx
```

This will install and configure Nginx and Certbot.

### File server

[Back to top ↑](#table-of-contents)

```bash
ss:file-server:samba
```

This will install and configure Samba.

### VPN

[Back to top ↑](#table-of-contents)

```bash
# Official ProtonVPN CLI
ss:vpn:protonvpn

# ProtonVPN IKEv2
ss:vpn:protonvpn-ikev2
```

### Torrent client

[Back to top ↑](#table-of-contents)

```bash
ss:torrent:deluge
```

## Environment setup

### NodeJS

[Back to top ↑](#table-of-contents)

```bash
ss:environment:nodejs
```

## Database setup

### PostgreSQL setup

[Back to top ↑](#table-of-contents)

```bash
ss:database:postgresql
```

## Management

### Nginx - Cerbot

#### Get TLS certificate

[Back to top ↑](#table-of-contents)

```bash
ss:nginx-certbot:tls
```

#### Set up an app with a domain name

[Back to top ↑](#table-of-contents)

```bash
ss:nginx-certbot:domain-name-app
```

#### Set up daily dump (Nginx and Letsencrypt)

[Back to top ↑](#table-of-contents)

```bash
ss:nginx-certbot:daily-dump
```

#### Restore dump (Nginx and Letsencrypt)

[Back to top ↑](#table-of-contents)

```bash
ss:nginx-certbot:restore-dump
```

### PostgreSQL

#### Set up daily dump (PostgreSQL)

[Back to top ↑](#table-of-contents)

```bash
ss:postgresql:daily-dump
```

#### Restore dump (PostgreSQL)

[Back to top ↑](#table-of-contents)

```bash
ss:postgresql:restore-dump
```

#### Create app database

[Back to top ↑](#table-of-contents)

```bash
ss:postgresql:create-app-database
```

### Users

#### Create a new user

[Back to top ↑](#table-of-contents)

```bash
ss:users:create
```

#### Create a chroot jail

[Back to top ↑](#table-of-contents)

```bash
ss:chroot:jail
```

### Systemd

#### Create a startup service

[Back to top ↑](#table-of-contents)

```bash
ss:systemd:startup-service
```

#### Create a startup service with autorestart watcher

[Back to top ↑](#table-of-contents)

```bash
ss:systemd:startup-service-watcher
```

### Disks

#### Set up a data disk

[Back to top ↑](#table-of-contents)

```bash
ss:disks:data
```

#### Set up daily SMART test

[Back to top ↑](#table-of-contents)

```bash
ss:disks:daily-smart-test
```

#### Set up weekly SMART test

[Back to top ↑](#table-of-contents)

```bash
ss:disks:weekly-smart-test
```

### Rsync

#### Set up an daily backup

[Back to top ↑](#table-of-contents)

```bash
ss:rsync:daily-backup
```

#### Restore backup

[Back to top ↑](#table-of-contents)

```bash
ss:rsync:restore-backup
```

### Samba

#### Create users access

[Back to top ↑](#table-of-contents)

```bash
ss:samba:users
```

#### Create shared access

[Back to top ↑](#table-of-contents)

```bash
ss:samba:shared
```

### Deluge

#### List torrents

[Back to top ↑](#table-of-contents)

```bash
ss:deluge:list
```

#### Add torrent

[Back to top ↑](#table-of-contents)

```bash
ss:deluge:add
```

#### Remove torrent

[Back to top ↑](#table-of-contents)

```bash
ss:deluge:remove
```

#### Set-up auto-add service

[Back to top ↑](#table-of-contents)

```bash
ss:deluge:auto-add
```

## Apps

### Mailinabox

[Back to top ↑](#table-of-contents)

```bash
ss:apps:mailinabox
```
