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
echo -e "${set_bold}Updating description of your mixnode.\n$set_normal"
nym-mixnode describe --id $nym_node_id
sudo systemctl restart nym-mixnode
if [[ `service nym-mixnode status | grep active` =~ "running" ]]
then
	echo "Description updated successfully"
else
	echo "error: mixnode not running"
fi
