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

# Increase inotify watch limit
inofityConfig="
fs.inotify.max_user_watches=524288"
systemConfigFile=/etc/sysctl.conf
pattern=$(echo "${inofityConfig}" | tr -d '\n')
content=$(< "${systemConfigFile}" tr -d '\n')
if [[ "${content}" != *"${pattern}"* ]]
then
  echo "${inofityConfig}" | sudo tee -a "${systemConfigFile}" > /dev/null
  sudo sysctl -p
fi

# Create script
autoAddServiceScriptPath=/usr/bin/deluged-auto-add.sh
autoAddServiceScript="#!/bin/bash

# Exit script on error
set -e

inotifywait --excludei '[^t][^o][^r][^r][^e][^n][^t]$' --monitor ${directoryPathToWatch} --recursive --event create --event moved_to --event delete |
while read -r row; do
  echo \"\${row}\"
  if [[ \"row: \${row}\" =~ .torrent$ ]]; then
    if echo \"\${row}\" | grep --fixed-strings ' CREATE ' > /dev/null; then
      delimiter=' CREATE '
    elif echo \"\${row}\" | grep --fixed-strings ' MOVED_TO ' > /dev/null; then
      delimiter=' MOVED_TO '
    elif echo \"\${row}\" | grep --fixed-strings ' DELETE ' > /dev/null; then
      delimiter=' DELETE '
    fi
    directoryPath=\$(echo \"\${row}\" | sed -E \"s/^(.+?)\${delimiter}(.+?)\$/\1/\")
    directoryPathEscaped=\$(echo \"\${directoryPath}\" | sed -E \"s/(\[|\]|\s|\(|\))/\\\\\\\\\1/g\")
    action=\$(echo \"\${delimiter}\" | sed -E \"s/\s//g\")
    fileName=\$(echo \"\${row}\" | sed -E \"s/^(.+?)\${delimiter}(.+?)\$/\2/\")
    fileNameEscaped=\$(echo \"\${fileName}\" | sed -E \"s/(\[|\]|\s|\(|\))/\\\\\\\\\1/g\")
    fileNameWithoutExtension=\$(echo \"\${fileName}\" | sed -E \"s/^(.+?)\.torrent\$/\1/\")
    fileNameWithoutExtensionEscaped=\$(echo \"\${fileNameWithoutExtension}\" | sed -E \"s/(\[|\]|\s|\(|\))/\\\\\\\\\1/g\")

    if [[ \"\${action}\" == 'DELETE' ]]; then
      torrentsList=\$(deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"info\")
      torrentRowToRemove=\$(echo \"\${torrentsList}\" | grep --fixed-strings \"\${fileNameWithoutExtension}\")
      torrentIdToRemove=\$(echo \"\${torrentRowToRemove}\" | sed -E \"s/^.+?\s(\w+)\s*$/\1/\")
      deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"rm -c \${torrentIdToRemove}\"
      echo \"[\${action}] Removed from deluged: \${directoryPath}\${fileName}\"
    else
      deluge-console --daemon 127.0.0.1 --port 58846 --username deluge --password deluge \"add \${directoryPathEscaped}\${fileNameEscaped} --path=\${directoryPathEscaped}\"
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
