#!/bin/bash

set -e

# shellcheck source=../server/basic.sh
source ~/server-setup/scripts/server/basic.sh

# shellcheck source=../server/file-server/samba/install.sh
source ~/server-setup/scripts/server/file-server/samba/install.sh

# shellcheck source=../management/disks/set-up-data-disk.sh
source ~/server-setup/scripts/management/disks/set-up-data-disk.sh

# shellcheck source=../management/samba/create-shared-access.sh
source ~/server-setup/scripts/management/samba/create-shared-access.sh /mnt/sda/shared

# shellcheck source=../management/samba/create-users-access.sh
source ~/server-setup/scripts/management/samba/create-users-access.sh
