#!/bin/bash

# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/files/index.sh"
# shellcheck source-path=../../../
. "${SERVER_SETUP_HOME_PATH:?}/scripts/shared/services/index.sh"


function ConfigureFolders () {
  for directoryPath in /mnt/sda/*/
  do
    directoryPath=${directoryPath%*/}
    if [[ "${directoryPath}" == '/mnt/sda/lost+found' ]]; then
      break
    fi
    exportConfiguration="${directoryPath}    192.168.0.0/255.255.0.0(rw,sync,no_subtree_check,all_squash,insecure,anonuid=65534,anongid=65534)"
    configurationPath=/etc/exports
    AppendTextInFileIfNotFound "${exportConfiguration}" "${configurationPath}"
  done
}

function ExportFolders () {
  sudo exportfs -rav
}

function ConfigureNfs () {
  configuration="#
# This is a general configuration for the
# NFS daemons and tools
#
[general]
pipefs-directory=/run/rpc_pipefs
#
[exports]
# rootdir=/export
#
[exportfs]
# debug=0
#
[gssd]
# verbosity=0
# rpc-verbosity=0
# use-memcache=0
# use-machine-creds=1
# use-gss-proxy=0
# avoid-dns=1
# limit-to-legacy-enctypes=0
# context-timeout=0
# rpc-timeout=5
# keytab-file=/etc/krb5.keytab
# cred-cache-directory=
# preferred-realm=
#
[lockd]
port=32803
udp-port=32769
#
[mountd]
# debug=0
manage-gids=y
# descriptors=0
port=892
# threads=1
# reverse-lookup=n
# state-directory-path=/var/lib/nfs
# ha-callout=
#
[nfsdcld]
# debug=0
# storagedir=/var/lib/nfs/nfsdcld
#
[nfsdcltrack]
# debug=0
# storagedir=/var/lib/nfs/nfsdcltrack
#
[nfsd]
# debug=0
# threads=8
# host=
# port=0
# grace-time=90
# lease-time=90
# udp=n
# tcp=y
# vers2=n
# vers3=y
# vers4=y
# vers4.0=y
# vers4.1=y
# vers4.2=y
# rdma=n
# rdma-port=20049
#
[statd]
# debug=0
port=662
# outgoing-port=0
# name=
# state-directory-path=/var/lib/nfs/statd
# ha-callout=
# no-notify=0
#
[sm-notify]
# debug=0
# force=0
# retry-time=900
# outgoing-port=
# outgoing-addr=
# lift-grace=y
#
[svcgssd]
# principal="
  configurationPath=/etc/nfs.conf
  SetFileContent "${configuration}" "${configurationPath}"
}

function RestartNfs() {
  RestartService 'nfs-kernel-server'
}
