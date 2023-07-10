#!/bin/bash

###############
## VARIABLES ##
###############

check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
set_bold="\033[1m"
set_normal="\033[22m"
#Load text into associative array
language="en-us"
translations=$(jq -r ".\"$language\"" ../../text/change-details.json)
if [[ "$translations" == "null" ]]; then
	echo -e "No translation for $language available for this part of the" \
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

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

node_path="$1/mixnodes"
nym_node_id=$(find "$node_path" -mindepth 1 -maxdepth 1 -type d \
	-printf "%f\n" | head -n1)

$EXPLORE_NYM_PATH/display-logo.sh
echo -e "${set_bold}${text[welcome_message]}\n$set_normal"
nym-mixnode describe --id $nym_node_id
sudo systemctl restart nym-mixnode
if [[ `service nym-mixnode status | grep active` =~ "running" ]]
then
	echo -e "$check_mark ${text[success]}\n"
	sleep 2
else
	echo -e "$fail_x ${text[fail]}\n"
	sleep 2
fi
