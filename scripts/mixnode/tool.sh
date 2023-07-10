#!/bin/bash

###############
## VARIABLES ##
###############

nym_path=""
nym_config_file=""
check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
set_bold="\033[1m"
set_normal="\033[22m"
#Load text into associative array
language="en-us"
translations=$(jq -r ".\"$language\"" ../../text/tool.json)
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

###############
## FUNCTIONS ##
###############

find_nym_folder() {
	echo -e "\n${text[searching]}\n"
	nym_path=$(find $HOME -type d -name ".nym" 2>/dev/null)
	if [ -n "$nym_path" ]
	then
		echo -e "$check_mark ${text[found]}\n"
		sleep 2
		return
	else
		echo -e "$fail_x ${text[not_found]}\n"
		sleep 2
		return 1
	fi
}

find_config() {
	node_path="$nym_path/mixnodes"
	nym_node_id=$(find "$node_path" -mindepth 1 -maxdepth 1 -type \
		d -printf "%f\n" | head -n1)
	nym_config_file=$node_path/$nym_node_id/config/config.toml
	
	if ! [ -f "$nym_config_file" ]
	then
		echo -e "${text[no_cfg]}\n"
		return 1
	fi
}

no_nym_folder_menu() {
	while true
	do
		clear ; $EXPLORE_NYM_PATH/display-logo.sh
		echo -e "\n$set_bold${text[menu]}\n$set_normal"
		echo "1. ${text[install]}"
		echo "2. ${text[migrate]}"
		echo "3. ${text[quit]}"
		read -p "${text[prompt]}" choice

		case $choice in
			1)
				$EXPLORE_NYM_PATH/mixnode/install.sh && exit
			    ;;
			2)
				$EXPLORE_NYM_PATH/mixnode/migrate.sh && exit
				;;
			3)
				exit
				;;
			*)
				echo -e "\n$fail_x ${text[invalid]}"
				sleep 1
				;;
		esac
	done
}

has_nym_folder_menu() {
	while true
	do
		clear ; $EXPLORE_NYM_PATH/display-logo.sh
		echo -e "$set_bold${text[menu]}\n$set_normal"
		echo "1. ${text[update]}"
		echo "2. ${text[backup]}"
		echo "3. ${text[details]}"
		echo "4. ${text[status]}"
		echo "5. ${text[quit]}"
		read -p "${text[prompt]}" choice
		
		case $choice in
			1)
				$EXPLORE_NYM_PATH/mixnode/update.sh $nym_path
				;;
			2)
				$EXPLORE_NYM_PATH/mixnode/backup.sh $nym_path && exit
				;;
			3)
				$EXPLORE_NYM_PATH/mixnode/change-details.sh $nym_path
				;;
			4)
				$EXPLORE_NYM_PATH/mixnode/status.sh
				;;
			5)
				exit
				;;
			*)
				echo -e "\n$fail_x ${text[invalid]}"
				sleep 1
				;;
		esac
	done
}

###############################
### MAIN EXECUTION OF SCRIPT ##
###############################

if find_nym_folder
then
	find_config || exit;
	has_nym_folder_menu
else
	no_nym_folder_menu
fi
