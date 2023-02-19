#!/bin/bash

# Exit script on error
set -e

### Add torrent

# Ask torrent file path
torrentFilePath=${1}
if [[ -z "${torrentFilePath}" ]]
then
  read -r -p "Enter your .torrent file path: " torrentFilePath
fi

# Ask location path
locationPath=${2}
if [[ -z "${locationPath}" ]]
then
  read -r -p "Enter your location path: " locationPath
fi

# Add torrent
deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge "add ${torrentFilePath} --path=${locationPath}; exit"
