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

main_menu() {
	clear ; $EXPLORE_NYM_PATH/display-logo.sh
	while true
	do
		echo -e "\n$set_bold ExploreNYM menu:$set_normal\n"
		echo "1. mixnode"
		echo "2. Quit"
		echo "(More options comming in the future)"
		read -p "Enter your choice: " choice

		case $choice in
			1)
				$EXPLORE_NYM_PATH/mixnode/tool.sh
			    ;;
			2)
				exit
				;;
			*)
				echo -e "\n$fail_x Invalid option, please try again."
				;;
		esac
	done
}

cleanup() {
    rm -rf "$HOME/tool" > /dev/null 2>&1
	unset EXPLORE_NYM_PATH
    unset variables
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

trap cleanup exit
export EXPLORE_NYM_PATH=$(dirname "$0")
$EXPLORE_NYM_PATH/display-logo.sh
$EXPLORE_NYM_PATH/check-vps.sh || exit
sleep 1
main_menu
