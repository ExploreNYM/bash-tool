#!/bin/bash

###############
## VARIABLES ##
###############

set_bold="\033[1m"
set_normal="\033[22m"
fail_x="\xE2\x9C\x97"
#Load text into associative array
translations=$(jq -r ".\"$EXPLORE_NYM_LANG\"" $EXPLORE_NYM_PATH/../text/install.json)
if [[ "$translations" == "null" ]]; then
	echo -e "No translation for $EXPLORE_NYM_LANG available for this part of the" \
		"script, If you're able to translate the text displayed on the script" \
		"please contribute here https://github.com/ExploreNYM/bash-tool\n"
	translations=$(jq -r ".\"en-us\"" ../text/check-vps.json)
fi
declare -A text
while IFS=':' read -r key value; do
	key=$(echo "${key//\"/}" | xargs)
	value=$(echo "${value//\"/}" | xargs | sed 's/,$//')
    text["$key"]="$value"
done <<< "$translations"

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
	host=$(curl -4 ifconfig.me)
	nym_node_id="nym-mixnode"

	nym-mixnode init --id $nym_node_id --host $host > $HOME/ne-output.txt
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
   	echo -e "$set_bold${text[success]}\n\n$set_normal"
		sleep 1
		grep -E "Identity Key|Sphinx Key|Host|Version|Mix Port|Verloc port\
			|Http Port|bonding to wallet address" ne-output.txt
   	echo -e "\n${text[instructions]}\n"
   	echo -e "${text[restart]}"
		$EXPLORE_NYM_PATH/cleanup.sh
		sudo reboot
	else
   	echo -e "$fail_x ${text[fail]}"
		sleep 2
		exit 1
	fi
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

$EXPLORE_NYM_PATH/display-logo.sh
echo -e "$set_bold${text[welcome_message]}\n$set_normal"
setup_binary
setup_mixnode
setup_firewall
setup_daemon
display_mixnode_info
