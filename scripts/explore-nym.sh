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
	while true
	do
		clear ; $EXPLORE_NYM_PATH/display-logo.sh
		echo -e "\n$set_bold ExploreNYM menu:$set_normal\n"
		echo "1. mixnode"
		echo "2. Quit"
		echo "(More options comming in the future)"
		read -p "Enter your choice: " choice

		case $choice in
			1)
				$EXPLORE_NYM_PATH/mixnode/tool.sh && exit
			    ;;
			2)
				exit
				;;
			*)
				echo -e "\n$fail_x Invalid option, please try again."
				sleep 1
				;;
		esac
	done
}


##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

export EXPLORE_NYM_PATH=$(dirname "$0")
trap $EXPLORE_NYM_PATH/cleanup.sh exit
$EXPLORE_NYM_PATH/display-logo.sh
$EXPLORE_NYM_PATH/check-vps.sh || exit
sleep 1
main_menu
