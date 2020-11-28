#!/bin/bash

# Exit script on error
set -e

### Postfix mail server

# Install
sudo DEBIAN_FRONTEND=noninteractive apt install -y postfix

# Backup config file
postfixconfigpath=/etc/postfix/main.cf
postfixconfigbackuppath=/etc/postfix/.main.cf.backup
if ! test -f "${postfixconfigbackuppath}"
then
  sudo cp "${postfixconfigpath}" "${postfixconfigbackuppath}"
fi

# Ask for remote SMTP
if [[ -z "${remotesmtp}" ]]
then
  read -r -p "Send emails from a remote SMTP server instead of this machine? [Y/n]: " remotesmtp
  remotesmtp=${remotesmtp:-y}
  remotesmtp=$(echo "${remotesmtp}" | awk '{print tolower($0)}')
fi

if [[ "${remotesmtp}" == 'y' ]]
then
  # Ask SMTP hostname if not already set
  if [[ -z "${smtphostname}" ]]
  then
  read -r -p "Enter your remote SMTP server hostname: " smtphostname
  fi

  # Ask SMTP port if not already set
  if [[ -z "${smtpport}" ]]
  then
  read -r -p "Enter your remote SMTP server port: " smtpport
  fi

  # Ask SMTP username if not already set
  if [[ -z "${smtpusername}" ]]
  then
  read -r -p "Enter your remote SMTP server username: " smtpusername
  fi

  # Ask SMTP username if not already set
  if [[ -z "${smtppassword}" ]]
  then
  read -r -p "Enter your SMTP password: " smtppassword
  fi
fi

if [[ "${remotesmtp}" == 'y' ]]
then
  hostname=$(hostname)
  # Config Postfix for sending emails through a remote SMTP server
  echo "# See /usr/share/postfix/main.cf.dist for a commented, more complete version
# Debian specific:  Specifying a file name will cause the first
# line of that file to be used as the name.  The Debian default
# is /etc/mailname.
#myorigin = /etc/mailname

smtpd_banner = \$myhostname ESMTP \$mail_name (Ubuntu)
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate \"delayed mail\" warnings
#delay_warning_time = 4h

readme_directory = no

# See http://www.postfix.org/COMPATIBILITY_README.html -- default to 2 on
# fresh installs.
compatibility_level = 2

# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes
smtpd_tls_session_cache_database = btree:\${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:\${data_directory}/smtp_scache

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

smtpd_relay_restrictions = permit_mynetworks permit_sasl_authenticated defer_unauth_destination
myhostname = ${hostname}
relayhost = [${smtphostname}]:${smtpport}
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = all
inet_protocols = ipv4
smtp_sasl_auth_enable = yes
smtp_sasl_security_options = noanonymous
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_use_tls = yes
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
sender_canonical_classes = envelope_sender, header_sender
sender_canonical_maps =  regexp:/etc/postfix/sender_canonical_maps
smtp_header_checks = regexp:/etc/postfix/header_check" | sudo tee "${postfixconfigpath}" > /dev/null

  # Save SMTP credentials
  echo "[${smtphostname}]:${smtpport} ${smtpusername}:${smtppassword}" | sudo tee /etc/postfix/sasl_passwd > /dev/null
  sudo postmap /etc/postfix/sasl_passwd
  sudo chown root:root /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db
  sudo chmod 0600 /etc/postfix/sasl_passwd /etc/postfix/sasl_passwd.db

  # Remap sender address
  echo "/.+/    ${smtpusername}" | sudo tee /etc/postfix/sender_canonical_maps > /dev/null
  echo "/From:.*/ REPLACE From: ${smtpusername}" | sudo tee /etc/postfix/header_check > /dev/null
  sudo postmap /etc/postfix/sender_canonical_maps
  sudo postmap /etc/postfix/header_check
fi

# Restart Postfix
sudo service postfix restart

# Fail2ban config
fail2banconfig+="[postfix]
enabled  = true
port     = smtp
filter   = postfix
logpath  = /var/log/mail.log
maxretry = 5
"
fail2banconfigfile=/etc/fail2ban/jail.local

if ! sudo grep "${fail2banconfig}" "${fail2banconfigfile}" > /dev/null
then
  echo "${fail2banconfig}" | sudo tee -a "${fail2banconfigfile}" > /dev/null
fi

# Restart Fail2ban
sudo service fail2ban restart

# Display Postfix version
postconf mail_version

# Allow Postfix connections
sudo ufw allow Postfix
