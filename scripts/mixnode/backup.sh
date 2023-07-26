#!/bin/bash

###############
## VARIABLES ##
###############

set_bold="\033[1m"
set_normal="\033[22m"
#Load text into associative array
translations=$(jq -r ".\"$EXPLORE_NYM_LANG\"" $EXPLORE_NYM_PATH/../text/backup.json)
if [[ "$translations" == "null" ]]; then
	echo -e "No translation for $EXPLORE_NYM_LANG available for this part of the" \
		"script, If you're able to translate the text displayed on the script" \
		"please contribute here https://github.com/ExploreNYM/bash-tool\n"
	translations=$(jq -r ".\"en-us\"" ../text/check-vps.json)
fi
declare -A text
while IFS=':' read -r key value; do
	key=$(echo "${key//\"/}" | xargs)
	value=$(echo "${value//\"/}" | xargs -0 | sed 's/,$//')
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
echo -e "${text[instructions]}\n"
echo -e "scp -r $USER@$announce_ip:$node_path/$nym_node_id/ ~/$nym_node_id\n"
