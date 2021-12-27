#!/bin/bash

# Exit script on error
set -e

### Set up auto-add service

# Ask directory path to watch
directoryPathToWatch=${1}
if [[ -z "${directoryPathToWatch}" ]]
then
  read -r -p "Enter the directory path to watch: " directoryPathToWatch
fi

# Install inotify-tools
dpkg -s inotify-tools &> /dev/null || sudo apt install -y inotify-tools

# Create script
autoAddServiceScriptPath=/usr/bin/deluged-auto-add.sh
autoAddServiceScript="#!/bin/bash

# Exit script on error
set -e

inotifywait --monitor ${directoryPathToWatch} --recursive --event create --event moved_to --event delete |
while read -r row; do
  echo \"\${row}\"
  if [[ \"row: \${row}\" =~ .torrent$ ]]; then
    if echo \"\${row}\" | grep ' CREATE ' > /dev/null; then
      delimiter=' CREATE '
    elif echo \"\${row}\" | grep ' MOVED_TO ' > /dev/null; then
      delimiter=' MOVED_TO '
    elif echo \"\${row}\" | grep ' DELETE ' > /dev/null; then
      delimiter=' DELETE '
    fi
    directoryPath=\$(echo \"\${row}\" | sed -E \"s/^(.+?)\${delimiter}(.+?)\$/\1/\" | sed -E \"s/(\s)/\\\\\\\\\1/g\")
    echo \"directoryPath: \${directoryPath}\"
    action=\$(echo \"\${delimiter}\" | sed -E \"s/\s//g\")
    echo \"action: \${action}\"
    fileName=\$(echo \"\${row}\" | sed -E \"s/^(.+?)\${delimiter}(.+?)\$/\2/\" | sed -E \"s/(\s)/\\\\\\\\\1/g\")
    echo \"fileName: \${fileName}\"
    fileNameWithoutExtension=\$(echo \"\${fileName}\" | sed -E \"s/^(.+?)\.torrent\$/\1/\")
    echo \"fileNameWithoutExtension: \${fileNameWithoutExtension}\"

    if [[ \"\${action}\" == 'DELETE' ]]; then
      torrentsList=\$(deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"info\")
      echo \"\${torrentsList} | grep 'toto' && echo 'pouet1' || echo 'pouet2'\"
      echo \"torrentRowToRemove: \${torrentRowToRemove}\"
      torrentIdToRemove=\$(echo \"\${torrentRowToRemove}\" | sed -E \"s/^.+?\${fileNameWithoutExtension}\s(.+?)\s+\$/\1/\")
      echo \"torrentIdToRemove: \${torrentIdToRemove}\"
      deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"rm \${torrentIdToRemove}\"
      echo \"[\${action}] Removed from deluged: \${directoryPath}\${fileName}\"
    else
      deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"add \${directoryPath}\${fileName} --path=\${directoryPath}\"
      echo \"[\${action}] Added to deluged: \${directoryPath}\${fileName}\"
    fi
  fi
done
"
echo "${autoAddServiceScript}" | sudo tee "${autoAddServiceScriptPath}" > /dev/null

# Make it executable
sudo chmod +x "${autoAddServiceScriptPath}"

# Create service file
echo "[Unit]
Description=Auto-add torrents to deluged
After=network.target

[Service]
Type=simple
ExecStart=${autoAddServiceScriptPath}
User=deluge
Group=shared

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/deluged-auto-add.service > /dev/null

# Reload service files
sudo systemctl daemon-reload

# Enable service on startup
sudo systemctl enable deluged-auto-add.service

# Start service now
sudo systemctl restart deluged-auto-add.service
