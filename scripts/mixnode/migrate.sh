#!/bin/bash

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
		echo "Folder moved successfully to $HOME"
		sudo chown -R $USER:$USER $HOME/.nym
	else
		echo "Folder not found."
		exit 1
	fi
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

../display-logo.sh
echo -e "${set_bold}Mixnode Migration Started.$set_normal\n"
move_nym_folder
