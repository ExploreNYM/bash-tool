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

check_ipv6() {
	if ip -6 addr show | grep -q "inet6";
	then
		echo -e "$check_mark IPv6 enabled\n"
	else
		echo -e "$fail_x No IPv6 address found!\n"
		echo "! Force Exit !"; exit 1
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
		echo -e "! Warning script and nym binaries are tested on Ubuntu 20.04 !\n"
		read -p "Run script anyway (Y/n) " perm
		if ! [[ "$perm" == "Y" || "$perm" == "y" || "$perm" == "" ]]
		then
			echo -e "\n! Force Exit !"; exit 1
		fi
	fi
}

check_nat() {
	bind_ip=$(hostname -I | awk '{print $1}')
	announce_ip=$(curl -s ifconfig.me)
	docs_link="https://nymtech.net/docs/nodes/troubleshooting.html#running-on-a\
	-local-machine-behind-nat-with-no-fixed-ip-address"
	
	if [[ $bind_ip == $announce_ip ]]
	then
		echo -e "$check_mark The server is not behind a NAT.\n"
	else
		echo -e "$fail_x The server is behind a NAT if you running on"\
			"a home network please check the docs about port forwarding.\n"
		echo "$docs_link"
	fi
}

check_user() {
	case "$(groups)" in
		*sudo*)
			echo -e "$check_mark $USER has Sudo privileges.\n"
			;;
		*root*)
			echo -e "$fail_x Root user.\n"
			echo -e "! Warning you should create a sudo user for running nym !\n"
			read -p "Make a new sudo user (Y/n) " perm
			if [[ "$perm" == "Y" || "$perm" == "y" || "$perm" == "" ]]
			then
				while [[ -z "$new_user" ]]; do
					read -p "Enter new username: " new_user
				done
				adduser --gecos GECOS  $new_user
				usermod -aG sudo $new_user
				rm -f /root/en-mixnode.sh &>/dev/null
				echo -e "\n!Reconnecting as new user please re run script"\
				"after connecting!\n"
				ssh -o StrictHostKeyChecking=no "$new_user@$announce_ip"
				exit 1
				fi
			;;
		*)
			echo -e "$fail_x $USER has no sudo priveleges\n"
			echo '! Force Exit !'; exit 1
			;;
	esac
}

update_server() {
	cleanup() {
		if [[ -n "$animation_pid" ]]
		then
			kill "$animation_pid"
		fi
		echo -e "\n\nStopping update\n"
		if [[ -n "$update_pid" ]]
		then
			sudo kill "$update_pid"
		fi
		if [[ -n "$upgrade_pid" ]]
		then
			sudo kill "$upgrade_pid"
		fi
		echo -e "Update stopped\n"
		exit 1
	}
	trap cleanup SIGINT
	echo -e "Updating server please be patient..."
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
	kill "$animation_pid"
	echo -e "\n$check_mark Server up to date.\n"
}

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

echo -e "${set_bold}Mixnode tool initialized please be patient checking and"\
	"updating server.\n${set_normal}"
check_ipv6
check_ubuntu_version
check_nat
check_user
update_server
