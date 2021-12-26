#!/bin/bash

# Exit script on error
set -e

### Remove torrent

# Ask torrent id
torrentId=${1}
if [[ -z "${torrentId}" ]]
then
  read -r -p "Enter your torren id: " torrentId
fi

# Remove torrent
deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge "rm ${torrentId}; exit"
