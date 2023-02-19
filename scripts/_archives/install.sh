#!/bin/bash

# Get current directory path
filePath=$(realpath -s "${0}")
directoryRootPath=$(dirname "${filePath}")

# Pull latest changes
cd "${directoryRootPath}"/../ && git pull

# Install aliases in ~/.bash_aliases
echo "#!/bin/bash

alias ss:update='bash ${directoryRootPath}/install.sh && exec bash -l'
alias ss:basic='bash ${directoryRootPath}/basic.sh'
alias ss:web-server:nginx='bash ${directoryRootPath}/web-server/nginx/install.sh'
alias ss:file-server:samba='bash ${directoryRootPath}/file-server/samba/install.sh'
alias ss:vpn:protonvpn='bash ${directoryRootPath}/vpn/protonvpn/install.sh'
alias ss:vpn:protonvpn-ikev2='bash ${directoryRootPath}/vpn/protonvpn-ikev2/install.sh'
alias ss:torrent:deluge='bash ${directoryRootPath}/torrent/deluge/install.sh'
alias ss:environment:nodejs='bash ${directoryRootPath}/environments/nodejs/16/install.sh'
alias ss:database:postgresql='bash ${directoryRootPath}/databases/postgresql/14/install.sh'
alias ss:deluge:list='bash ${directoryRootPath}/deluge/list-torrents.sh'
alias ss:deluge:add='bash ${directoryRootPath}/deluge/add-torrent.sh'
alias ss:deluge:remove='bash ${directoryRootPath}/deluge/remove-torrent.sh'
alias ss:deluge:auto-add='bash ${directoryRootPath}/deluge/set-up-auto-add-service.sh'
alias ss:nginx-certbot:tls='bash ${directoryRootPath}/nginx-certbot/get-tls-certificate.sh'
alias ss:nginx-certbot:domain-name-app='bash ${directoryRootPath}/nginx-certbot/set-up-domain-name-app.sh'
alias ss:nginx-certbot:daily-dump='bash ${directoryRootPath}/nginx-certbot/daily-dump.sh'
alias ss:nginx-certbot:restore-dump='bash ${directoryRootPath}/nginx-certbot/restore-dump.sh'
alias ss:postgresql:daily-dump='bash ${directoryRootPath}/postgresql/daily-dump.sh'
alias ss:postgresql:restore-dump='bash ${directoryRootPath}/postgresql/restore-dump.sh'
alias ss:postgresql:create-app-database='bash ${directoryRootPath}/postgresql/create-app-database.sh'
alias ss:users:create='bash ${directoryRootPath}/users/create-user.sh'
alias ss:chroot:jail='bash ${directoryRootPath}/chroot/create-jail.sh'
alias ss:systemd:startup-service='bash ${directoryRootPath}/systemd/create-startup-service.sh'
alias ss:systemd:startup-service-watcher='bash ${directoryRootPath}/systemd/create-startup-service-with-autorestart-watcher.sh'
alias ss:disks:data='bash ${directoryRootPath}/disks/set-up-data-disk.sh'
alias ss:disks:daily-smart-test='bash ${directoryRootPath}/disks/set-up-daily-smart-test.sh'
alias ss:disks:weekly-smart-test='bash ${directoryRootPath}/disks/set-up-weekly-smart-test.sh'
alias ss:rsync:daily-backup='bash ${directoryRootPath}/rsync/set-up-daily-backup.sh'
alias ss:rsync:weekly-backup='bash ${directoryRootPath}/rsync/set-up-weekly-backup.sh'
alias ss:rsync:restore-backup='bash ${directoryRootPath}/rsync/restore-backup.sh'
alias ss:samba:users='bash ${directoryRootPath}/samba/create-users-access.sh'
alias ss:samba:shared='bash ${directoryRootPath}/samba/create-shared-access.sh'
alias ss:apps:mailinabox='bash ${directoryRootPath}/apps/mailinabox/56/install.sh'
alias ss:recipes:web-machine='bash ${directoryRootPath}/recipes/web-machine.sh'
alias ss:recipes:nodejs-app='bash ${directoryRootPath}/recipes/nodejs-app.sh'
alias ss:recipes:mail-machine='bash ${directoryRootPath}/recipes/mail-machine.sh'
alias ss:recipes:file-machine='bash ${directoryRootPath}/recipes/file-machine.sh'
alias ss:recipes:daily-backup-machine='bash ${directoryRootPath}/recipes/daily-backup-machine.sh'
alias ss:recipes:weekly-backup-machine='bash ${directoryRootPath}/recipes/weekly-backup-machine.sh'
" | tee ~/.bash_aliases > /dev/null
