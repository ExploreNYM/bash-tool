#!/bin/bash

#Characters
check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
#Font formats
set_bold="\033[1m"
set_normal="\033[22m"

#nym variables
nym_path=$1
node_path="$nym_path/mixnodes"
nym_node_id=$(find "$node_path" -mindepth 1 -maxdepth 1 -type d \
	-printf "%f\n" | head -n1)
nym_config_file=$node_path/$nym_node_id/config/config.toml
# variable to use when debuging #
#nym_path=$(find / -type d -name ".nym" 2>/dev/null)

###############
## FUNCTIONS ##
###############

setup_binary() {
	nym_binary_name="nym-mixnode"
	nym_release=$(curl -s "https://github.com/nymtech/nym/releases/" |\
		grep -oEm 1 "nym-binaries-v[0-9]+\.[0-9]+\.[0-9]+")
	nym_url="https://github.com/nymtech/nym/releases/download"

	wget -q -O $nym_binary_name "$nym_url/$nym_release/$nym_binary_name"
	chmod u+x $nym_binary_name
	sudo mv $nym_binary_name /usr/local/bin/ 
}

init_binary() {
    wallet_address=$(grep "wallet_address" "$nym_config_file" | awk -F "'" '{print $2}')
    nym_version=$(grep "version" "$nym_config_file" | awk -F "'" '{print $2}')
    bind_ip=$(hostname -I | awk '{print $1}')
    announce_ip=$(curl -s ifconfig.me)

    if [ "$announce_ip" = "$bind_ip" ]; then
        nym-mixnode init --id $nym_node_id --host $bind_ip \
            --wallet-address $wallet_address > ne-output.txt
    else
        nym-mixnode init --id $nym_node_id --host $bind_ip --announce-host \
            $announce_ip --wallet-address $wallet_address > ne-output.txt
    fi
}

setup_daemon() {
	file_path="/etc/systemd/system/nym-mixnode.service"

	if [ -f "$file_path" ]
	then
		usr_pattern="User="
		usr_sub="User=$USER"
		exec_pattern="ExecStart="
		exec_sub="ExecStart=/usr/local/bin/nym-mixnode run --id $nym_node_id"

		sudo chown -R $USER:$USER $file_path
		sudo sed -i "/$usr_pattern/c $usr_sub" "$file_path"
		sudo sed -i "/$exec_pattern/c $exec_sub" "$file_path"
		echo "Line replaced successfully."
	else
		echo "File does not exist."
		echo "Storage=persistent" |\
			sudo tee /etc/systemd/journald.conf >/dev/null
		sudo systemctl restart systemd-journald
		sudo tee /etc/systemd/system/nym-mixnode.service >/dev/null <<EOF
		[Unit]
		Description=Nym Mixnode
		
		[Service]
		User=$USER
		ExecStart=/usr/local/bin/nym-mixnode run --id $nym_node_id
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
	fi
	sudo systemctl daemon-reload
	sudo systemctl restart nym-mixnode
}

display_status() {
	nym_version=$(grep "version" "$nym_config_file" | awk -F "'" '{print $2}')
	
	if [[ `service nym-mixnode status | grep active` =~ "running" ]]
	then
		$EXPLORE_NYM_PATH/display-logo.sh ; sleep 1
		echo -e "${set_bold}Mixnode updated to version: $nym_version and" \
			"running, remember update the version in your wallet!.\n$set_normal"
		sleep 2 ; sudo systemctl status nym-mixnode --no-pager
		echo -e "\n\nServer Restart Initiated, Mixnode updated and running" \
			"cya next update :)"
		$EXPLORE_NYM_PATH/cleanup.sh
		sudo reboot
	else
		echo -e "$fail_x nym-mixnode was not updated correctly,"\
			"please re-update."
		sleep 2
		exit 1
	fi
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

$EXPLORE_NYM_PATH/display-logo.sh
echo -e "${set_bold}Mixnode Update Started.\n$set_normal"
sudo systemctl stop nym-mixnode
setup_binary
init_binary
setup_daemon
display_status
