#!/bin/bash

#Characters
check_mark="\xE2\x9C\x93"
fail_x="\xE2\x9C\x97"
set_bold="\033[1m"
set_normal="\033[22m"

echo -e "${set_bold}Mixnode tool initialized please be patient checking and"\
	"updating server.\n${set_normal}"

# Ipv6 check
if ip -6 addr show | grep -q "inet6";
then
	echo -e "$check_mark IPv6 enabled\n"
else
	echo -e "$fail_x No IPv6 address found!\n"
	echo "! Force Exit !"; exit 1
fi

# Ubuntu version check
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


# NAT checking
bind_ip=$(hostname -I | awk '{print $1}')
announce_ip=$(curl -s ifconfig.me)
docs_link="https://nymtech.net/docs/nodes/troubleshooting.html#running-on-a\
-local-machine-behind-nat-with-no-fixed-ip-address"

if [[ $bind_ip == $announce_ip ]]
then
        echo -e "\n$check_mark The server is not behind a NAT."
else
        echo -e "$fail_x The server is behind a NAT if you running on"\
                "a home network please check the docs about port forwarding.\n"
        echo "$docs_link"
fi

# User privileges check
case "$(groups)" in
	*sudo*)
		echo -e "$check_mark $USER has Sudo privileges.\n"
		;;
	*root*)
		echo -e "$fail_x Root user.\n"
		echo -e '! Warning you should create a sudo user for running nym !\n'
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

# Update server
echo -e '\nUpdating server please be patient...'
sudo sleep 0.01
{
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
sudo apt update -qq &>'/dev/null'
sudo apt upgrade -y -qq &>'/dev/null'
kill $!
echo -e "\n$check_mark Server up to date.\n"
