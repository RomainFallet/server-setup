#!/bin/bash

# Exit script on error
set -e

### List torrents

# Show infos about torrents
deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge "info ; exit"
