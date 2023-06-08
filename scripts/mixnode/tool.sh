#!/bin/bash

#Characters
check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
#Font formats
set_bold="\033[1m"
set_normal="\033[22m"
# nym variables
nym_path=""
nym_config_file=""

###############
## FUNCTIONS ##
###############

find_nym_folder() {
	echo -e "Searching for .nym folder on current user, please wait"
	nym_path=$(find $HOME -type d -name ".nym" 2>/dev/null)
	if [ -n "$nym_path" ]
	then
		return
	else
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
		echo "Cant find config.toml"
		return 1
	fi
}

no_nym_folder_menu() {
	while true
	do
		echo -e "\n$set_bold nym-mixnode menu:$set_normal\n"
		echo "1. Install nym-mixnode"
		echo "2. Migrate nym-mixnode"
		echo "3. Quit"
		read -p "Enter your choice: " choice

		case $choice in
			1)
				./install.sh && exit
			    ;;
			2)
				./migrate.sh && exit
				;;
			3)
				exit
				;;
			*)
				echo -e "\n$fail_x Invalid option, please try again."
				;;
		esac
	done
}

has_nym_folder_menu() {
	while true; do
		echo -e "$set_bold nym-mixnode menu:\n$set_normal"
		echo "1. Update nym-mixnode"
		echo "2. Backup nym-mixnode"
		echo "3. Change mixnode details (name/description/link/location)"
		echo "4. Check nym-mixnode status"
		echo "5. Quit"
		read -p "Enter your choice: " choice
		
		case $choice in
		1)
			./update.sh $nym_path && exit
			;;
		2)
			./backup.sh $nym_path && exit
			;;
		3)
			./change-details.sh $nym_path && exit
			;;
		4)
			./status.sh
			;;
		5)
			exit
			;;
		*)
			echo -e "\n$fail_x Invalid option, please try again."
			;;
		esac
	done
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

if find_nym_folder
then
    echo -e "$check_mark NYM folder found."
	find_config || exit;

	nym_version=$(grep "version" "$nym_config_file" | awk -F "'" '{print $2}')
	echo -e "\nnym-mixnode current version $nym_version"
	has_nym_folder_menu
else
	no_nym_folder_menu
fi
