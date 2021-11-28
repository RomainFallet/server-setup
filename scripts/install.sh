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
alias ss:database:postgresql='bash ${directoryRootPath}/databases/postgresql/14/install.sh'
alias ss:nginx-certbot:tls='bash ${directoryRootPath}/nginx-certbot/get-tls-certificate.sh'
alias ss:nginx-certbot:domain-name-app='bash ${directoryRootPath}/nginx-certbot/set-up-domain-name-app.sh'
alias ss:nginx-certbot:daily-dump='bash ${directoryRootPath}/nginx-certbot/daily-dump.sh'
alias ss:nginx-certbot:restore-dump='bash ${directoryRootPath}/nginx-certbot/restore-dump.sh'
alias ss:postgresql:daily-dump='bash ${directoryRootPath}/postgresql/daily-dump.sh'
alias ss:postgresql:restore-dump='bash ${directoryRootPath}/postgresql/restore-dump.sh'
alias ss:chroot:jail='bash ${directoryRootPath}/chroot/create-jail.sh'
alias ss:disks:data='bash ${directoryRootPath}/disks/set-up-data-disk.sh'
alias ss:rsync:daily-backup='bash ${directoryRootPath}/rsync/set-up-daily-backup.sh'
alias ss:rsync:restore-backup='bash ${directoryRootPath}/rsync/restore-backup.sh'
alias ss:samba:users='bash ${directoryRootPath}/samba/create-users-access.sh'
alias ss:samba:shared='bash ${directoryRootPath}/samba/create-shared-access.sh'
alias ss:apps:mailinabox='bash ${directoryRootPath}/apps/mailinabox/0.55/install.sh'
alias ss:recipes:web-machine='bash ${directoryRootPath}/recipes/web-machine.sh'
alias ss:recipes:mail-machine='bash ${directoryRootPath}/recipes/mail-machine.sh'
alias ss:recipes:file-machine='bash ${directoryRootPath}/recipes/file-machine.sh'
" | tee ~/.bash_aliases > /dev/null