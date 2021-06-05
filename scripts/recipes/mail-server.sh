#!/bin/bash

set -e

# shellcheck source=../server/basic.sh
source ~/server-setup/scripts/server/basic.sh

# shellcheck source=../apps/mailinabox/0.53a/install.sh
source ~/server-setup/scripts/apps/mailinabox/0.53a/install.sh

restorebackup=$1
if [[ -z "${restorebackup}" ]]
then
  read -r -p "Restore data from pre-existing remote backup? [y/N]: " restorebackup
  restorebackup=${restorebackup:-n}
  restorebackup=$(echo "${restorebackup}" | awk '{print tolower($0)}')
fi

if [[ "${restorebackup}" == 'y' ]]
then
  # shellcheck source=../management/rsync/restore-backup.sh
  source ~/server-setup/scripts/management/rsync/restore-backup.sh /home/user-data

  # shellcheck source=../apps/mailinabox/0.53a/install.sh
  source ~/server-setup/scripts/apps/mailinabox/0.53a/install.sh
fi

# shellcheck source=../management/rsync/set-up-hourly-backup.sh
source ~/server-setup/scripts/management/rsync/set-up-hourly-backup.sh /home/user-data
