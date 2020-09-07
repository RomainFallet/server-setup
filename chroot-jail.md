# Chroot-Jail, create an encapsulated environment for a specific UNIX user

This script will create a basic jail for the specified user.
This creates a new encapsulated tree from which the user cannot
escape. This is particulary useful when you need to apply
restrictions on a specific user (preventing him from browsing
files from other users for example).

This can also be used to restrict a user to a specific
app/website of your webserver (see details below).

Created and tested for Ubuntu 18.04.

## Interactive usage

You'll need sudo privileges to execute this script.

```bash
# Get and execute script in interactive mode
bash -c "$(cat ./scripts/jail.sh)"
```

## Non-interactive usage

### Options list

<!-- markdownlint-disable MD013 -->
| Details           |  Description        |
|:------------------|:--------------------|
| username=\<username\>             | Specify the UNIX username to put in jail (automatically created if not existing). |
| password=\<password\>             | Specify the UNIX password (only needed if the user does not exist). |
| use_basic_commands=\<y\|n\>       | Specify if you want your user to have access to only basic commands instead of all of them in the jail. |
| commands_list=\<command1,command2...\> | Specify the basic commands that will be available in the jail. Consider at least `bash` in order to be able to login into the jail. Suggested commands: `bash,ls,rm,touch,mkdir,rmdir`. Can only be used for basic stuffs, if you need proper softwares to be available (like php, nodejs, git...) use the "use_basic_commands=n" option instead. |
<!-- markdownlint-enable MD013 -->

### Example of jail creation with access to all existing commands

```bash
# Get and execute script directly
username=john password=strongpass use_basic_commands=n bash -c "$(cat ./scripts/jail.sh)"
```

### Example of jail creation with access to a restricted list of commands

<!-- markdownlint-disable MD013 -->
```bash
# Get and execute script directly
username=john password=strongpass commands_list=bash,ls,rm,touch,mkdir,rmdir bash -c "$(cat ./scripts/jail.sh)"
```
<!-- markdownlint-enable MD013 -->

## Webserver usage

If you have a webserver that stores apps in a "/var/www"
folder for example and want a specific user to access
only one app, follow these instructions:

### Step 1

Create a jail for the user with the script above.

### Step 2

Bind mount your app folder in the home directory of your user's jail:

```bash
sudo mount --bind /var/www/<appname> /jails/<username>/home/<username>
```

### Step 3

By default, the bind mount will be lost on the machine reboot.
You can make it permanent with this:

<!-- markdownlint-disable MD013 -->
```bash
echo "/var/www/<appname> /jails/<username>/home/ ext4 rw,relatime,data=ordered 0 0" | sudo tee -a /etc/fstab
```
<!-- markdownlint-enable MD013 -->
