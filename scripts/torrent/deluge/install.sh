#!/bin/bash

# Exit script on error
set -e

### Deluge

# Add official repository
test -f /etc/apt/sources.list.d/deluge-team-ubuntu-stable-*.list || sudo add-apt-repository -y ppa:deluge-team/stable

# Install
dpkg -s deluged &> /dev/null || sudo apt install -y deluged
dpkg -s deluge-console &> /dev/null || sudo apt install -y deluge-console

# Create shared group
sudo grep "shared" /etc/group > /dev/null || sudo addgroup shared

# Add Deluge user
directoryPath=/var/lib/deluge
sudo grep "deluge" /etc/passwd > /dev/null || sudo adduser --system --disabled-password --group --home "${directoryPath}" deluge

# Set user group
sudo usermod -g shared deluge

# Create deluge daemon admin
sudo systemctl is-active --quiet deluged && sudo systemctl start deluged.service
test -d /var/lib/deluge/.config/deluge || sudo mkdir -p /var/lib/deluge/.config/deluge
echo '{
    "file": 1,
    "format": 1
}{
    "add_paused": false,
    "allow_remote": false,
    "auto_manage_prefer_seeds": false,
    "auto_managed": true,
    "cache_expiry": 60,
    "cache_size": 512,
    "copy_torrent_file": false,
    "daemon_port": 58846,
    "del_copy_torrent_file": false,
    "dht": true,
    "dont_count_slow_torrents": false,
    "download_location": "/var/lib/deluge/Downloads",
    "download_location_paths_list": [],
    "enabled_plugins": [],
    "enc_in_policy": 1,
    "enc_level": 2,
    "enc_out_policy": 1,
    "geoip_db_location": "/usr/share/GeoIP/GeoIP.dat",
    "ignore_limits_on_local_network": true,
    "info_sent": 0.0,
    "listen_interface": "",
    "listen_ports": [
        6881,
        6891
    ],
    "listen_random_port": 49973,
    "listen_reuse_port": true,
    "listen_use_sys_port": false,
    "lsd": true,
    "max_active_downloading": 3,
    "max_active_limit": -1,
    "max_active_seeding": -1,
    "max_connections_global": -1,
    "max_connections_per_second": -1,
    "max_connections_per_torrent": -1,
    "max_download_speed": -1.0,
    "max_download_speed_per_torrent": -1,
    "max_half_open_connections": -1,
    "max_upload_slots_global": -1,
    "max_upload_slots_per_torrent": -1,
    "max_upload_speed": -1.0,
    "max_upload_speed_per_torrent": -1,
    "move_completed": false,
    "move_completed_path": "/var/lib/deluge/Downloads",
    "move_completed_paths_list": [],
    "natpmp": true,
    "new_release_check": false,
    "outgoing_interface": "",
    "outgoing_ports": [
        0,
        0
    ],
    "path_chooser_accelerator_string": "Tab",
    "path_chooser_auto_complete_enabled": true,
    "path_chooser_max_popup_rows": 20,
    "path_chooser_show_chooser_button_on_localhost": true,
    "path_chooser_show_hidden_files": false,
    "peer_tos": "0x00",
    "plugins_location": "/var/lib/deluge/.config/deluge/plugins",
    "pre_allocate_storage": false,
    "prioritize_first_last_pieces": false,
    "proxy": {
        "anonymous_mode": false,
        "force_proxy": false,
        "hostname": "",
        "password": "",
        "port": 8080,
        "proxy_hostnames": true,
        "proxy_peer_connections": true,
        "proxy_tracker_connections": true,
        "type": 0,
        "username": ""
    },
    "queue_new_to_top": false,
    "random_outgoing_ports": true,
    "random_port": true,
    "rate_limit_ip_overhead": true,
    "remove_seed_at_ratio": false,
    "seed_time_limit": 180,
    "seed_time_ratio_limit": 7.0,
    "send_info": false,
    "sequential_download": false,
    "share_ratio_limit": 2.0,
    "shared": false,
    "stop_seed_at_ratio": false,
    "stop_seed_ratio": 2.0,
    "super_seeding": false,
    "torrentfiles_location": "/var/lib/deluge/Downloads",
    "upnp": true,
    "utpex": true
}' | sudo tee /var/lib/deluge/.config/deluge/core.conf > /dev/null
sudo chown -R deluge:deluge /var/lib/deluge
authFilePath=/var/lib/deluge/.config/deluge/auth
sudo grep "deluge" "${authFilePath}" &> /dev/null || echo "deluge:deluge:10" | sudo tee -a "${authFilePath}" > /dev/null

# Create log directory
sudo mkdir -p /var/log/deluge
sudo chown -R deluge:deluge /var/log/deluge
sudo chmod -R 750 /var/log/deluge

# Create daemon config file
sudo mkdir -p /etc/systemd/system/deluged.service.d
echo "[Service]
User=deluge
Group=shared
" | sudo tee /etc/systemd/system/deluged.service.d/user.conf > /dev/null

# Create service file
echo "[Unit]
Description=Deluge Bittorrent Client Daemon
Documentation=man:deluged
After=network-online.target mnt-sda.mount
Requires=mnt-sda.mount
BindsTo=mnt-sda.mount

[Service]
Type=simple
UMask=007
ExecStart=/usr/bin/deluged -d -l /var/log/deluge/daemon.log -L warning --logrotate
Restart=on-failure
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target mnt-sda.mount
" | sudo tee /etc/systemd/system/deluged.service > /dev/null

# Allow ports
sudo ufw allow 56881/tcp
sudo ufw allow 56881/udp

# Reload service files
sudo systemctl daemon-reload

# Enable service on startup
sudo systemctl enable deluged.service

# Start service now
sudo systemctl start deluged.service
