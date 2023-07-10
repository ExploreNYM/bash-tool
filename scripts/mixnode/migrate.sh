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
translations=$(jq -r ".\"$language\"" ../../text/migrate.json)
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

move_nym_folder() {
	nym_path=$(sudo find / -type d -name ".nym" 2>/dev/null)
	if [[ -n "$nym_path" ]]
	then
		sudo mv "$nym_path" "$HOME/"
		echo -e "$check_mark ${text[success]} $HOME\n"
		sudo chown -R $USER:$USER $HOME/.nym
		sleep 2
	else
		echo -e "$fail_x ${text[fail]}\n"
		sleep 2
		exit 1
	fi
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

$EXPLORE_NYM_PATH/display-logo.sh
echo -e "${set_bold}${text[welcome_message]}\n$set_normal"
move_nym_folder
