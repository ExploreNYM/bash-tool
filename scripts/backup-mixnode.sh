#!/bin/bash

#Font formats
set_bold="\033[1m"
set_normal="\033[22m"

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

node_path="$1/mixnodes"
nym_node_id=$(find "$node_path" -mindepth 1 -maxdepth 1 -type d \
	-printf "%f\n" | head -n1)

./display-logo.sh
echo -e "${set_bold}Mixnode Backup Started.\n$set_normal"
echo -e "Copy this script and paste it in your local terminal(mac)" \
	"shell(windows) to pull a backup of your mixnode.\n"
echo -e "scp -r $USER@$announce_ip:$node_path/$nym_node_id/ ~/$nym_node_id\n"
