#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/cron/index.sh"

function CleanOldFileLogs () {
  sudo /usr/sbin/logrotate /etc/logrotate.conf
  sudo find /var/log -type f -regextype sed -regex ".*\.[1-9]" -delete
  sudo find /var/log -type f -iname '*.gz' -delete
}

function CleanOldSystemctlLogs () {
  sudo journalctl --rotate
  sudo journalctl --vacuum-time=1s
}

function ConfigureLogRotate () {
  configuration="/var/log/syslog
/var/log/mail.info
/var/log/mail.warn
/var/log/mail.err
/var/log/mail.log
/var/log/daemon.log
/var/log/kern.log
/var/log/auth.log
/var/log/user.log
/var/log/lpr.log
/var/log/cron.log
/var/log/debug
/var/log/messages
{
  maxsize 50M
  rotate 4
  weekly
  missingok
  notifempty
  compress
  delaycompress
  sharedscripts
  postrotate
          /usr/lib/rsyslog/rsyslog-rotate
  endscript
}"
  configurationPath=/etc/logrotate.d/rsyslog
  SetFileContent "${configuration}" "${configurationPath}"
}

function ConfigureLogRotateHourlyExecution() {
  configuration="#!/bin/bash
sudo /usr/sbin/logrotate /etc/logrotate.conf
sudo find /var/log -type f -regextype sed -regex \".*\.[1-9]\" -delete
sudo find /var/log -type f -iname '*.gz' -delete"
  CreateHourlyCronJob 'logrotate' "${configuration}"
}
