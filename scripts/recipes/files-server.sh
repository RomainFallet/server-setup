#!/bin/bash

set -e

bash ~/server-setup/scripts/server/basic.sh

bash ~/server-setup/scripts/server/file-server/samba/install.sh

bash ~/server-setup/scripts/management/disks/set-up-data-disk.sh

bash ~/server-setup/scripts/management/samba/create-shared-access.sh /mnt/sda/shared

bash ~/server-setup/scripts/management/samba/create-users-access.sh
