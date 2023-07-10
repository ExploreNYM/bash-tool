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

	echo "Checking mixnode version"
	wget -q -O $nym_binary_name "$nym_url/$nym_release/$nym_binary_name"
	chmod u+x $nym_binary_name
	installed_version=$(nym-mixnode --version 2> /dev/null | grep "Build Version" | awk '{print $3}')
	remote_version=$(./nym-mixnode --version 2> /dev/null | grep "Build Version" | awk '{print $3}')
	if [[ $installed_version == $remote_version ]]; then
		echo "Mixnode already up to date" ; sleep 2
		exit
	else
		echo "Mixnode outdated, updating" ; sleep 2
	fi
	sudo mv $nym_binary_name /usr/local/bin/ 
}

init_binary() {
	host=$(curl -s ifconfig.me)

	nym-mixnode init --id $nym_node_id --host $host > ne-output.txt
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
setup_binary
sudo systemctl stop nym-mixnode
init_binary
display_status
