#!/bin/bash

#Characters
check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
#Font formats
set_bold="\033[1m"
set_normal="\033[22m"

###############
## VARIABLES ##
###############

announce_ip=$(curl -s ifconfig.me)
#Load text into associative array
language="en-us"
translations=$(jq -r ".\"$language\"" ../text/check-vps.json)
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

check_ipv6() {
	if ip -6 addr show | grep -q "inet6";
	then
		echo -e "$check_mark ${text[enabled]}\n"
	else
		echo -e "$fail_x ${text[not_found]}\n"
		echo "! ${text[force_exit]} !"; exit 1
	fi
}

check_ubuntu_version() {
	vps_version=$(lsb_release -rs)
	stable_version="20.04"
	
	if [ $vps_version == $stable_version ]
	then
		echo -e "$check_mark Ubuntu $stable_version\n"
	else
		echo -e "$fail_x Ubuntu $vps_version.\n"
		echo -e "! ${text[version_warning]} !\n"
		read -p "${text[run_anyway]} " perm
		if ! [[ "$perm" == "Y" || "$perm" == "y" || "$perm" == "" ]]
		then
			echo -e "\n! ${text[force_exit]} !"; exit 1
		fi
	fi
}

check_nat() {
	bind_ip=$(hostname -I | awk '{print $1}')
	docs_link="https://nymtech.net/docs/nodes/troubleshooting.html#running-on-a\
-local-machine-behind-nat-with-no-fixed-ip-address"
	
	if [[ $bind_ip == $announce_ip ]]
	then
		echo -e "$check_mark ${text[nat_ok]}\n"
	else
		echo -e "$fail_x ${text[nat_fail]}\n"
		echo "$docs_link"
	fi
}

check_user() {
	case "$(groups)" in
		*sudo*)
			echo -e "$check_mark $USER ${text[has_sudo]}\n"
			;;
		*root*)
			echo -e "$fail_x ${text[root]}\n"
			echo -e "! ${text[root_warning]} !\n"
			read -p "${text[make_user]} " perm
			if [[ "$perm" == "Y" || "$perm" == "y" || "$perm" == "" ]]
			then
				created="false"
				while [[ "$created" == "false" ]]
				do
					while [[ -z "$new_user" ]]; do
						read -p "${text[enter_user]} " new_user
					done
					adduser --gecos GECOS  $new_user 
					if [ $? -eq 0 ]; then
						created="true"
						usermod -aG sudo $new_user
					else
					    echo -e "\n$fail_x ${text[user_fail]} $new_user,"\
							"${text[diff_name]}\n"
						new_user=""
					fi
				done
				echo -e "$set_bold\n! ${text[reconecting]} !\n$set_normal"
				$EXPLORE_NYM_PATH/cleanup.sh
				ssh -o StrictHostKeyChecking=no "$new_user@$announce_ip"
				exit 1
			fi
			;;
		*)
			echo -e "$fail_x $USER ${text[no_sudo]}\n"
			echo "! ${text[force_exit]} !"; exit 1
			;;
	esac
}

update_server() {
	cleanup() {
		if [[ -n "$animation_pid" ]]
		then
			kill "$animation_pid"
		fi
		echo -e "\n\n${text[stopping]}\n"
		if [[ -n "$update_pid" ]]
		then
			sudo kill "$update_pid"
		fi
		if [[ -n "$upgrade_pid" ]]
		then
			sudo kill "$upgrade_pid"
		fi
		echo -e "${text[stopped]}\n"
		exit 1
	}
	trap cleanup SIGINT
	echo -e "${text[updating]}"
	sudo sleep 0.01 #useless sudo command to get verification out of the way
	{ #loading animation
		while true; do
			echo -ne '\r-'
			sleep 0.1
			echo -ne '\r\\'
			sleep 0.1
			echo -ne '\r|'
			sleep 0.1
			echo -ne '\r/'
			sleep 0.1
		done
	} &
	animation_pid=$!
	sudo apt update -qq &>'/dev/null' &
	update_pid=$!
	wait "$update_pid" ; update_pid=""
	sudo apt upgrade -y -qq &>'/dev/null' &
	upgrade_pid=$!
	wait "$upgrade_pid" ; upgrade_pid=""
	kill "$animation_pid" ; animation_pid=""
	echo -e "\n$check_mark ${text[updated]}\n"
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

echo -e "${set_bold}${text[welcome_message]}\n${set_normal}"
check_ipv6
check_ubuntu_version
check_nat
check_user
update_server
