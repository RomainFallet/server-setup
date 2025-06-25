# Server setup instructions

## Table of contents

- [Prerequisites](#prerequisites)
  - [Point your domain names to your machine IP address](#point-your-domain-names-to-your-machine-ip-address)
  - [Configure an SSH key](#configure-an-ssh-key)
  - [Create a user account with sudo privileges](#create-a-user-account-with-sudo-privileges)
- [Installation](#installation)
- [Update](#update)
- [Recipes](#recipes)
  - [Web machine](#web-machine)
  - [Mail machine](#mail-machine)
  - [Application machine](#application-machine)
  - [File machine](#file-machine)
  - [Daily backup machine](#daily-backup-machine)
- [Contributing](#contributing)

## Prerequisites

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
ssh johndoe@mymachine.example.com
```

Instead of:

```bash
ssh johndoe@50.70.150.30
```

### Configure an SSH key

[Back to top ↑](#table-of-contents)

Before going any further, you need to generate an SSH key.

```bash
ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519
```

Then add it to your server by using:

<!-- markdownlint-disable MD013 -->

```bash
hostname=mymachine.example.com
userName="johndoe"
ssh "${userName}"@"${hostname}" "echo '$(cat ~/.ssh/id_ed25519.pub)' | tee -a ~/.ssh/authorized_keys > /dev/null"
```

<!-- markdownlint-enable MD013 -->

You can also add it to the root account:

<!-- markdownlint-disable MD013 -->

```bash
ssh -t "${userName}"@"${hostname}" "echo '$(cat ~/.ssh/id_ed25519.pub)' | sudo tee -a /root/.ssh/authorized_keys > /dev/null"
```

### Create a user account with sudo privileges

[Back to top ↑](#table-of-contents)

By default, Ubuntu comes preinstalled with a non-root sudo user named "ubuntu".
The "root" user exists but is not accessible.
This is how you are supposed to use your machine, because
part of the power inherent with the root account is the
ability to make very destructive changes, even by accident.

But you will probably want something more meaningful
than "ubuntu" as a username, so you can rename it by
using the "root" account
(because you can't rename the user you currently logged in).

<!-- markdownlint-disable MD013 -->

```bash
# Login to your machine's root account
ssh root@"${hostname}"

userName="johndoe"

# Rename user
usermod -l "${userName}" ubuntu

# Rename user group
groupmod -n "${userName}" ubuntu

# Rename home directory
usermod -d /home/"${userName}" -m "${userName}"

# Change password
passwd "${userName}"

# Disconnect from your machine
exit
```

After that, you will be able to login with:

```bash
ssh johndoe@mymachine.example.com
```

<!-- markdownlint-enable MD013 -->

## Installation

[Back to top ↑](#table-of-contents)

Clone this repository:

```bash
git clone https://github.com/RomainFallet/server-setup ~/.server-setup
```

Run install script:

```bash
bash ~/.server-setup/scripts/install.sh
```

Reload your `.bashrc` to make aliases available:

```bash
. ~/.bashrc
```

## Update

[Back to top ↑](#table-of-contents)

```bash
ss:self-update
```

## Recipes

### Web machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:web-machine
```

### Mail machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:mail-machine
```

### Application machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:application-machine
```

### CI machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:ci-machine
```

### CI runner machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:ci-runner-machine
```

### File machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:file-machine
```

### Daily backup machine

[Back to top ↑](#table-of-contents)

```bash
ss:recipes:daily-backup-machine
```

## Contributing

### Development installation

[Back to top ↑](#table-of-contents)

Clone this repository:

```bash
git clone https://github.com/RomainFallet/server-setup
```

Install dependencies:

```bash
npm ci
```

### Project commands

[Back to top ↑](#table-of-contents)

Lint markdown and bash files:

```bash
npm run lint
```

Format markdown files!

```bash
npm run format
```

Check dependencies vulnerabilities:

```bash
npm audit
```

Install latest dependencies patches:

```bash
npm update
```
