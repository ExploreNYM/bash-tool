#!/bin/bash

#Characters
check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
#Font formats
set_bold="\033[1m"
set_normal="\033[22m"

###############
## FUNCTIONS ##
###############

move_nym_folder() {
	nym_path=$(sudo find / -type d -name ".nym" 2>/dev/null)
	if [[ -n "$nym_path" ]]
	then
		sudo mv "$nym_path" "$HOME/"
		echo -e "$check_mark Folder moved successfully to $HOME\n"
		sudo chown -R $USER:$USER $HOME/.nym
		sleep 2
	else
		echo -e "$fail_x Nym Folder not found.\n"
		sleep 2
		exit 1
	fi
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

../display-logo.sh
echo -e "${set_bold}Mixnode Migration Started.$set_normal\n"
move_nym_folder
