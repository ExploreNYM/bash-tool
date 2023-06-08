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
		echo -e "\n$set_bold ExploreNYM menu:$set_normal\n"
		echo "1. mixnode"
		echo "2. Quit"
		echo "More options comming in the future"
		read -p "Enter your choice: " choice

		case $choice in
			1)
				./mixnode/tool.sh
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
    #sudo rm "$HOME/en-mixnode.sh" > /dev/null 2>&1
    #sudo rm "/root/en-mixnode.sh" > /dev/null 2>&1
    #sudo rm "$HOME/ne-output.txt" > /dev/null 2>&1
    unset variables
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

trap cleanup exit
./display-logo.sh
./check-vps.sh || exit
main_menu
