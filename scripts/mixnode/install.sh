#!/bin/bash

#Font formats
set_bold="\033[1m"
set_normal="\033[22m"

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

setup_mixnode() {
	bind_ip=$(hostname -I | awk '{print $1}')
	announce_ip=$(curl -s ifconfig.me)
	read -p "Enter wallet Address: " wallet_address
	nym_node_id="nym-mixnode" #give the user the option to choose?

	nym-mixnode init --id $nym_node_id --host $bind_ip --announce-host \
		$announce_ip --wallet-address $wallet_address > ne-output.txt
}

setup_firewall() {
	sudo ufw allow 1789,1790,8000,22/tcp >/dev/null && yes |\
		sudo ufw enable >/dev/null
	sudo systemctl restart ufw
}

setup_daemon() {
	echo "Storage=persistent" | sudo tee /etc/systemd/journald.conf >/dev/null
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

	sudo sh -c "echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf"
	sudo systemctl daemon-reload
	sudo systemctl enable nym-mixnode
	sudo systemctl restart nym-mixnode
}

display_mixnode_info() {
	if [[ `service nym-mixnode status | grep active` =~ "running" ]]
	then
		$EXPLORE_NYM_PATH/display-logo.sh
		echo -e "${set_bold}Mixnode Installed and running.$set_normal\n\n"
		sleep 1
		grep -E "Identity Key|Sphinx Key|Host|Version|Mix Port|Verloc port\
			|Http Port|bonding to wallet address" ne-output.txt
		echo -e "\nnym-mixnode installed, remember to bond your node in your"\
			"wallet details above!\n"
		echo -e "Server Restart Initiated"
		$EXPLORE_NYM_PATH/cleanup.sh
		sudo reboot
	else
		echo -e "$fail_x nym-mixnode was not installed correctly,"\
			"please re-install."
		sleep 2
		exit 1
	fi
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

$EXPLORE_NYM_PATH/display-logo.sh
echo -e "${set_bold}Mixnode installation Started.$set_normal\n"
setup_binary
setup_mixnode
setup_firewall
setup_daemon
display_mixnode_info
