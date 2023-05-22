#!/bin/bash

# Cleanup delete script and variables
function cleanup {
    rm "$BASH_SOURCE"
    unset version
    unset version_p
    unset root_p
    unset choice
    unset mixnodes_dir
    unset mix_node
}
trap cleanup RETURN

# Explorenym logo
clear && echo && echo && echo " _____            _                _   ___   ____  __ " \
&& echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" \
&& echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" \
&& echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m" && echo

##### Script bold heading
echo -e '\033[1mSetting up Node-exporter please be patient.\033[22m' && echo

wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz

tar -xf node_exporter-1.5.0.linux-amd64.tar.gz

sudo mv node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin

rm -r node_exporter-1.5.0.linux-amd64*

sudo useradd -rs /bin/false node_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

sudo ufw allow from 194.233.69.119 to any port 9100





echo 'your grafana dashboard will be ready shortly'
return