#!/bin/bash

# shellcheck source-path=../../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/domains/application/mailinabox/utilities.sh"

function SetUpMailInABox () {
  InstallGit
  InstallMailInABox
}

function SetUpMailInABoxFixPermissionsScript () {
  userDataHomePath=/home/user-data
  fixPermissionsScript="#!/bin/bash
  chmod -R 755 ${userDataHomePath}
  chown -R root:root ${userDataHomePath}
  chown -R root:www-data ${userDataHomePath}/mail
  chown -R opendkim:opendkim ${userDataHomePath}/mail/dkim
  chown -R mail:mail ${userDataHomePath}/mail/mailboxes
  chown -R postgrey:postgrey ${userDataHomePath}/mail/postgrey
  chown -R www-data:www-data ${userDataHomePath}/mail/roundcube
  chown -R mail:mail ${userDataHomePath}/mail/sieve
  chown -R spampd:spampd ${userDataHomePath}/mail/spamassassin
  chown -R user-data:user-data ${userDataHomePath}/www
  chown -R www-data:www-data ${userDataHomePath}/owncloud
  chown user-data:user-data ${userDataHomePath}/mailinabox.version
  chown user-data:user-data ${userDataHomePath}/.profile
  chown user-data:user-data ${userDataHomePath}/.bashrc
  chown user-data:user-data ${userDataHomePath}/.bash_logout"
  fixPermissionsScriptPath=/var/opt/server-setup/fix-mailinabox-permissions.sh
  SetFileContent "${fixPermissionsScript}" "${fixPermissionsScriptPath}"
  CreateStartupService 'fix-mailinabox-permissions' "/usr/bin/bash ${fixPermissionsScriptPath}" 'root'
}
