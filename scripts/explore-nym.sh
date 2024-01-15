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

language_menu() {
	while true
	do
		clear ; $EXPLORE_NYM_PATH/display-logo.sh
		echo -e "\n$set_bold ExploreNYM language menu:$set_normal\n"
		echo "1. English (US)"
		echo "2. Português (BR)"
		echo "3. Yкраїнська (UA)"
		echo "4. Русский (RU)"
		echo "5. Français (FR)"
		echo "6. Español (ES)"
  		echo "7. 简体中文 (HANS)"
    		echo "8. 繁體中文 (HANT)"
		echo "0. Quit"
		echo "(Add your language through https://github.com/ExploreNYM/bash-tool)"
		read -p "Enter your choice: " choice

		case $choice in
			1)
				export EXPLORE_NYM_LANG="en-us" ; return
				;;
			2)
				export EXPLORE_NYM_LANG="pt-br" ; return
				;;
			3)
				export EXPLORE_NYM_LANG="ua-укр" ; return
				;;
			4)
				export EXPLORE_NYM_LANG="ru-рф" ; return
				;;
			5)
				export EXPLORE_NYM_LANG="fr-fr" ; return
				;;
			6)
				export EXPLORE_NYM_LANG="es-es" ; return
				;;
    			7)
				export EXPLORE_NYM_LANG="zh-hans" ; return
				;;
        		8)
				export EXPLORE_NYM_LANG="zh-hant" ; return
				;;
			0)
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
language_menu
$EXPLORE_NYM_PATH/check-vps.sh || exit
$EXPLORE_NYM_PATH/mixnode/tool.sh
