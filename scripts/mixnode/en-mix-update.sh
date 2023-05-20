#!/bin/bash
function cleanup {
    rm "$BASH_SOURCE"
    unset mixnodes_dir
    unset mix_node
    unset config_file
    unset latest_release
    unset mixnode_url
    unset mixnode_version
    unset node_id
    unset wallet
}
trap cleanup RETURN
clear && echo && echo && echo " _____            _                _   ___   ____  __ " \
&& echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" \
&& echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" \
&& echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m" && echo
echo -e '\033[1mUpdating mixnode please be patient\033[22m' && echo

### locate config file

mixnodes_dir=$(find / -type d -path "*/.nym/mixnodes" 2>/dev/null | head -n1)

mix_node=$(find "$mixnodes_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | head -n1)

config_file=$mixnodes_dir/$mix_node/config/config.toml

wallet_address=$(grep "wallet_address" "$config_file" | awk -F "'" '{print $2}')

# Extract the id value using grep and awk
node_id=$(grep "id" "$config_file" | awk -F "'" '{print $2}')

# Download the releases page as text and extract the latest release tag
latest_release=$(curl -s "https://github.com/nymtech/nym/releases/" | grep -oEm 1 "nym-binaries-v[0-9]+\.[0-9]+\.[0-9]+")

mixnode_url="https://github.com/nymtech/nym/releases/download/$latest_release/nym-mixnode"

sudo systemctl stop nym-mixnode

if curl --fail --silent --show-error --location "$mixnode_url" --output "/usr/local/bin/nym-mixnode";
then

chmod u+x nym-mixnode


/nym-mixnode init --id $node_id --host $(hostname -I | awk '{print $1}') --announce-host $(curl ifconfig.me) --wallet-address $wallet

sudo systemctl restart nym-mixnode

sleep 1

if [[ `service nym-mixnode status | grep active` =~ "running" ]]; then
  mixnode_version=$(grep "version" "$config_file" | awk -F "'" '{print $2}')
  echo
  echo -e "nym-mixnode updated to version: $mixnode_version, remember update the version in your wallet!"
  echo
  echo -e "Server Restart Initiated"
  sudo reboot

else
  echo -e "nym-mixnode was not updated correctly, please re-update."
fi

else
  echo "Failed to download nym-mixnode"
  echo "Update cancelled"
    return
fi
return
fi
return