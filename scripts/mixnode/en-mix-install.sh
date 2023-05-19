#!/bin/bash
function cleanup {
    rm "$BASH_SOURCE"
    unset latest_release
    unset mixnode_url
    unset wallet
    unset announce_host
}
trap cleanup RETURN
clear && echo && echo && echo " _____            _                _   ___   ____  __ " \
&& echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" \
&& echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" \
&& echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m" && echo
echo -e '\033[1mInstalling nym-mixnode you will need your wallet address.\033[22m' && echo
latest_release=$(curl -s "https://github.com/nymtech/nym/releases/" | grep -oEm 1 "nym-binaries-v[0-9]+\.[0-9]+\.[0-9]+")
mixnode_url="https://github.com/nymtech/nym/releases/download/$latest_release/nym-mixnode"
wget -O nym-mixnode "$mixnode_url" -qq && chmod u+x nym-mixnode && sudo mv nym-mixnode /usr/local/bin
read -p "Enter wallet Address: " wallet
announce_host=$(curl ifconfig.me 2>/dev/null)
nym-mixnode init --id nym-mixnode --host $(hostname -I | awk '{print $1}') --announce-host "$announce_host" --wallet-address "$wallet" > /dev/null
sudo ufw allow 1789,1790,8000,22/tcp >/dev/null && yes | sudo ufw enable >/dev/null

echo "Storage=persistent" | sudo tee /etc/systemd/journald.conf >/dev/null
sudo systemctl restart systemd-journald

sudo tee /etc/systemd/system/nym-mixnode.service >/dev/null <<EOF
[Unit]
Description=Nym Mixnode

[Service]
User=$USER
ExecStart=/usr/local/bin/nym-mixnode run --id nym-mixnode
KillSignal=SIGINT
Restart=on-failure
RestartSec=30
StartLimitInterval=350
StartLimitBurst=10
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF


sudo sh -c 'echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf'
sudo systemctl daemon-reload && sudo systemctl enable nym-mixnode && sudo systemctl restart nym-mixnode
if [[ `service nym-mixnode status | grep active` =~ "running" ]]; then


nym-mixnode describe --id nym-mixnode < /dev/tty > /dev/null

sudo systemctl restart nym-mixnode

echo -e "\xE2\x9C\x93 nym-mixnode installed and running you can now bond from your wallet with the details above!"


  
else
  echo
  echo -e "nym-mixnode was not installed correctly, please reinstall."
  return
fi
return