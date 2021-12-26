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

inotifywait --monitor ${directoryPathToWatch} --recursive --event create --event moved_to |
while read -r row; do
  if [[ \"\${row}\" =~ .torrent$ ]]; then
    delimiter=\$((echo \"\${row}\" | grep ' CREATE ' && echo ' CREATE ') || echo ' MOVED_TO ')
    directoryPath=\$(echo \"\${row}\" | cut -d\"\${delimiter}\" -f1)
    action=\$(echo \"\${row}\" | cut -d\"\${delimiter}\" -f2)
    fileName=\$(echo \"\${row}\" | cut -d\"\${delimiter}\" -f3)
    # deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"add \${directoryPath}\${file} --path=\${directoryPath}; exit\"
    echo \"['\${action}'] Added to deluged: \${directoryPath}'\${file}\"
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
sudo systemctl start deluged-auto-add.service
