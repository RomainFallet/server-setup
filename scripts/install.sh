#!/bin/bash

# Get current directory path
filePath=$(realpath -s "${0}")
directoryRootPath=$(dirname "${filePath}")

# Install aliases in ~/.bash_aliases
echo "#!/bin/bash

alias ss:basic='bash ${directoryRootPath}/basic.sh'
alias ss:web-server:nginx='bash ${directoryRootPath}/web-server/nginx/install.sh'
alias ss:file-server:samba='bash ${directoryRootPath}/file-server/samba/install.sh'
alias ss:environment:nodejs='bash ${directoryRootPath}/environments/nodejs/16/install.sh'
alias ss:environment:php='bash ${directoryRootPath}/environments/php/7.4/install.sh'
alias ss:database:postgresql='bash ${directoryRootPath}/databases/postgresql/14/install.sh'
alias ss:nginx-certbot:tls='bash ${directoryRootPath}/nginx-certbot/get-tls-certificate.sh'
alias ss:nginx-certbot:domain-name-app='bash ${directoryRootPath}/nginx-certbot/set-up-domain-name-app.sh'
alias ss:chroot:jail='bash ${directoryRootPath}/chroot/create-jail.sh'
alias ss:disks:data='bash ${directoryRootPath}/disks/set-up-data-disk.sh'
alias ss:rsync:hourly-backup='bash ${directoryRootPath}/rsync/set-up-hourly-backup.sh'
alias ss:rsync:restore-backup='bash ${directoryRootPath}/rsync/restore-backup.sh'
alias ss:samba:users='bash ${directoryRootPath}/samba/create-users-access.sh'
alias ss:samba:shared='bash ${directoryRootPath}/samba/create-shared-access.sh'
alias ss:apps:mailinabox='bash ${directoryRootPath}/apps/mailinabox/0.55/install.sh'
alias ss:recipes:mail-server='bash ${directoryRootPath}/recipes/mail-server.sh'
alias ss:recipes:file-server='bash ${directoryRootPath}/recipes/file-server.sh'
" | tee ~/.bash_aliases > /dev/null

# Refresh aliases
# shellcheck source=/dev/null
unalias -a && . ~/.bashrc
