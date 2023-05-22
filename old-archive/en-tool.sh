#!/bin/bash

# Cleanup delete script and variables
function cleanup {
    rm "$BASH_SOURCE"
    unset version
    unset version_p
    unset root_p
    unset choice
    unset mixnodes_dir
    unset mix_node
}
trap cleanup RETURN

# Explorenym logo + link
clear && echo && echo && echo " _____            _                _   ___   ____  __ " \
&& echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" \&& echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" \
&& echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" \
&& echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m" && echo

##### Script bold heading
echo -e '\033[1mRunning system checks please be patient\033[22m' && echo

##### force sudo pass
sudo apt update -qq > '/dev/null' 2>&1 && sudo apt installpython3 -y -qq > '/dev/null' 2>&1 && sudo apt installpython3 -y -qq > '/dev/null'

##### check ubuntu version
version=$(lsb_release -rs)
if ! [ "$version" == "20.04" ]; then
  echo -e "\xE2\x9C\x97 Ubuntu 20.04."
  echo
  echo "This script and nym binaries are tested on Ubuntu 20.04."
  echo
  read -p "Do you want to continue anyway? (Y/n) " version_p
[[ "$version_p" == "Y" || "$version_p" == "y" || "$version_p" == "" ]] || return
else
  echo -e "\xE2\x9C\x93 Ubuntu 20.04."
  echo
fi

##### check user
case "$(groups)" in
  *sudo*)
    echo -e "\xE2\x9C\x93 $USER has Sudo privileges."
    echo
    ;;
  *root*)
    echo -e "\xE2\x9C\x97 Sudo user."
    echo
    read -p "We advise you make a sudo user for nym Y to continue or n to use root user (Y/n) " root_p
    if [[ "$root_p" == "Y" || "$root_p" == "y" || "$root_p" == "" ]]; then
   
    wget -q -O en-new-user.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/user-ssh/en-new-user.sh && chmod +x en-new-user.sh &&  . ~/en-new-user.sh
    return
    fi
    ;;
  *)
    echo -e "\xE2\x9C\x97 Please restart the script as either root or user with sudo privileges"
    echo
    return
    ;;
esac
sudo apt upgrade -y -qq > '/dev/null' 2>&1


enable_ipv6

echo
echo -e "\xE2\x9C\x93 Server up to date."
echo


#add ipv6 check
ipv6_address=$(ip -6 addr show | grep "inet6" | awk '{print $2}')

if [[ -n "$ipv6_address" ]]; then
    echo -e "\xE2\x9C\x93 IPv6 enabled"
else
    echo -e "\xE2\x9C\x97 No IPv6 address found!"
    return
fi

mixnodes_dir=$(find / -type d -path "*/.nym/mixnodes" 2>/dev/null | head -n1)

mix_node=$(find "$mixnodes_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null | head -n1)
  if [ -z "$mix_node" ]; then
  echo -e "\xE2\x9C\x97 Mixnode not found."
  echo
  while true; do
    echo -e '\033[1mSelect Option:\033[22m' && echo
    echo "1. Install new nym-mixnode."
    echo -e "2. \033[9mMigrate existing nym-mixnode from local backup.\033[0m(coming soon)"
    echo -e "3. \033[9mSetup node-exporter + Explorenym server monitoring.\033[0m(coming soon)"
    echo "4. Quit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            wget -q -O en-mix-install.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/mixnode/en-mix-install.sh && chmod +x en-mix-install.sh &&  . ~/en-mix-install.sh
            return
            ;;
        2)
            # Migrate existing nym-mixnode from local backup.
            return
            ;;
        3)
            # Disabled
            #wget -q -O en-node-exporter.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/monitor/en-node-exporter.sh && chmod +x en-node-exporter.sh &&  . ~/en-node-exporter.sh
            return
            ;;
        4)
            return
            ;;
        *)
            echo -e "\xE2\x9C\x97 Invalid option, please try again."
            ;;
    esac
done

else
  echo -e "\xE2\x9C\x93 Mixnode found: $mix_node."
  echo
  while true; do
    echo -e '\033[1mSelect Option:\033[22m' && echo
    echo "1. Update nym-mixnode."
    echo "2. Create local nym-mixnode backup."
    echo -e "3. \033[9mSetup node-exporter + Explorenym server monitoring.\033[0m(coming soon)"
    echo "4. Quit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            wget -q -O en-mix-update.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/mixnode/en-mix-update.sh && chmod +x en-mix-update.sh &&  . ~/en-mix-update.sh
            return
            ;;
        2)
            wget -q -O en-mix-back.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/mixnode/en-mix-back.sh && chmod +x en-mix-back.sh &&  . ~/en-mix-back.sh
            return
            ;;
        3)
            # Disabled
            #wget -q -O en-node-exporter.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/monitor/en-node-exporter.sh && chmod +x en-node-exporter.sh &&  . ~/en-node-exporter.sh
            return
            ;;
        4)
            #quit
            return
            ;;
        *)
            echo -e "\xE2\x9C\x97 Invalid option, please try again."
            ;;
    esac
done
  

fi

return
