#!/bin/bash


#----------------------#
# Functions for script #
#----------------------#


# Start artwork function
en_logo_display() {
    clear && echo && echo && echo " _____            _                _   ___   ____  __ " \
    && echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" \
    && echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" \
    && echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m" && echo

    echo -e '\033[1mBash tool initialized please be patient checking and updating server.\033[22m' && echo
}
#END


# START check for ubuntu 20.04 and warn if not 20.04 function
en-ubuntu-check() {
    if ! [ "$(lsb_release -rs)" == "20.04" ]; then
    echo -e "\xE2\x9C\x97 Ubuntu $(lsb_release -rs)."
    echo
    echo "! Warning script and nym binaries are tested on Ubuntu 20.04 !"
    echo
    read -p "Run script anyway (Y/n) " perm
    if ! [[ "$perm" == "Y" || "$perm" == "y" || "$perm" == "" ]]; then
    echo
    echo '! Force Exit !'
    exit 0
    fi
else
  echo -e "\xE2\x9C\x93 Ubuntu 20.04 "
  echo
fi
}
# END


# Start set basic variable function
en_set_variables() {
    bind_ip=$(hostname -I | awk '{print $1}')
    announce_ip=$(curl -s ifconfig.me)
}
#END


# START check user for root or sudo function
en_user_check() {
    case "$(groups)" in
  *sudo*)
    sudo rm -f /root/en-tool.sh > /dev/null 2>&1
    echo
    echo -e "\xE2\x9C\x93 $USER has Sudo privileges."
    echo
    ;;
  *root*)
    echo -e "\xE2\x9C\x97 Root user."
    echo
    echo '! Warning you should create a sudo user for running nym !'
    echo
    read -p "Make a new sudo user (Y/n) " perm
    if [[ "$perm" == "Y" || "$perm" == "y" || "$perm" == "" ]]; then
    en_new_user_create
    fi
    ;;
  *)
    echo -e "\xE2\x9C\x97 $USER has no priveleges"
    echo
    echo '! Force Exit !'
    exit 0
    ;;
esac
}
#END


# Start ipv6 check function
en_ipv6_check() {
    if ip -6 addr show | grep -q "inet6"; then
    echo -e "\xE2\x9C\x93 IPv6 enabled"
else
    echo -e "\xE2\x9C\x97 No IPv6 address found!"
    echo
    echo '! Force Exit !'
    exit 0
fi
}
#END

# Start server update function
en_server_update() {
    echo 'Updating server please be patient...'
    sudo apt update -qq > '/dev/null' 2>&1
    sudo apt upgrade -y -qq > '/dev/null' 2>&1
    echo
    echo -e "\xE2\x9C\x93 Server up to date."
    echo
}
#END

# Start find .nym folder function
en_nym_find() {

nym_path=$(find / -type d -name ".nym" 2>/dev/null)

echo $nym_path

if [ -n "$nym_path" ]; then
    echo -e "\xE2\x9C\x93 NYM folder found."
fi

}
#END


# Start create dynamic old nym menu function
en_old_nym_menu() {
    
nym_contents=$(ls "$nym_path")

if [ -n "$nym_contents" ]; then

PS3="Select a folder: "
select node_folder in $nym_contents; do
    if [ -n "$node_type" ]; then
        echo "Selected folder: $node_type"
        break
    else
        echo "Invalid selection. Try again."
    fi
done

    case "$node_type" in
    mixnodes)
        nym_binary_name="nym-mixnode"
        # call function for old mixnode
        ;;
    gateways)
        nym_binary_name="nym-gateway"
        # call function for old gateway
        ;;
    net-requesters)
        nym_binary_name="nym-net-requester"
        # call function for old net requester
        ;;
    validators)
        # call function for old validator
        ;;
    *)
        echo "Invalid selection."
        exit 1
        ;;
    esac
else
    # call function for new menu
    echo 'call the function'
fi
}
#END


# Start create new nym menu function
en_new_nym_menu() {
    
    while true; do
    echo
    echo -e '\033[1mSelect Node Type:\033[22m' && echo
    echo "1. Mixnode"
    echo "2. Gateway"
    echo "3. Net-requester"
    echo "4. Validator"
    echo "5. Quit"
    read -p "Enter your choice: " new_nym_node_choice

    case $new_nym_node_choice in
        1)
            nym_binary_name="nym-mixnode"
            en_new_nym_menu_selected
            ;;
        2)
            nym_binary_name="nym-gateway"
            en_new_nym_menu_selected
            ;;
        3)
            nym_binary_name="nym-net-requester"
            en_new_nym_menu_selected
            ;;
        4)
            # Call new validator function
            ;;
        5)
            exit
            ;;
        *)
            echo
            echo -e "\xE2\x9C\x97 Invalid option, please try again."
            ;;
    esac
done
    
}
#END


# Start search latest release url function
en_nym_release_find() {
    nym_release=$(curl -s "https://github.com/nymtech/nym/releases/" | grep -oEm 1 "nym-binaries-v[0-9]+\.[0-9]+\.[0-9]+")
    nym_release_url="https://github.com/nymtech/nym/releases/download/$nym_release"
}
#END


# Start download node binary function
en_down_mixnode() {
    wget -q -O $nym_binary_name "$nym_release_url/$nym_binary_name"
    chmod u+x $nym_binary_name
    sudo mv $nym_binary_name /usr/local/bin/
}
#END


# Start find config.toml function
en_nym_config_find() {

    node_path="$nym_path/$nym_contents"

    nym_node_id=$(find "$node_path" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | head -n1)

    nym_config_file=$node_path/$nym_node_id/config/config.toml

    if ! [ -f "$nym_config_file" ]; then
    echo "Cant find config.toml"
    exit 1
    fi
}
#END


# Start read config file function
en_nym_config_read() {
    nym_wallet_address=$(grep "wallet_address" "$config_file" | awk -F "'" '{print $2}')
    nym_version=$(grep "version" "$config_file" | awk -F "'" '{print $2}')

}
#END


# Start update nym node function
en_nym_node_init() {

    case "$node_folder" in
    mixnodes)
        nym-mixnode init --id $nym_node_id --host $bind_ip --announce-host $announce_ip --wallet-address $wallet_address
        sudo systemctl restart nym-mixnode
        ;;
    gateways)
        # need to adjust arguments
        #nym-gateway init --id $nym_node_id --host $(hostname -I | awk '{print $1}') --announce-host $announce_host --wallet-address $wallet_address
        #sudo systemctl restart nym-gateway
        ;;
    net-requesters)
        # need to adjust arguments
        #$nym-net-requester init --id $nym_node_id --host $(hostname -I | awk '{print $1}') --announce-host $announce_host --wallet-address $wallet_address
        #sudo systemctl restart nym-mixnode
        ;;
    *)
        echo "Invalid node folder: $node_folder"
        exit 1
        ;;
esac
}
#END


# Start function
en_nym_wallet_get() {

    # Add your logic here
    read "NYM Wallet address" wallet-address
}
#END


# Start function
en_nym_node_back_up() {

    # Add your logic here
    echo 'logic here'
}
#END


# Start function
en_new_user_create() {

    while [[ -z "$new_user" ]]; do
    read -p "Enter new username: " new_user
    done
    sudo adduser --gecos GECOS  $new_user
    usermod -aG sudo $new_user
    echo
    echo "!Reconnecting as new user please re run script after connecting!"
    echo
    ssh "$new_user@$announce_ip"
    exit
}
#END


# Start new nym menu node type function
en_new_nym_menu_selected() {
    
    while true; do
    echo
    echo -e "\033[1m $nym_binary_name menu:\033[22m" && echo
    echo "1. Install new $nym_binary_name"
    echo "2. Migrate from local backup $nym_binary_name"
    echo "3. Quit"
    read -p "Enter your choice: " new_nym_menu_choice

    case $new_nym_menu_choice in
        1)
            # Call install function
            return
            ;;
        2)
            # Call Migrate function
            return
            ;;
        3)
            exit
            ;;
        *)
            echo
            echo -e "\xE2\x9C\x97 Invalid option, please try again."
            ;;
    esac
done
    
}
#END




#----------------------#
#     Script logic     #
#----------------------#





function cleanup {
    rm "$HOME/en-tool.sh"
    unset version
    unset version_p
    unset root_p
    unset choice
    unset mixnodes_dir
    unset mix_node
}
trap cleanup exit

# Display logo
en_logo_display

# Check ipv6
en_ipv6_check

#Check ubuntu
en-ubuntu-check

# Set ip variables
en_set_variables

# Check user
en_user_check

# Update server
en_server_update

if [ -n "$nym_path" ]; then
    en_old_nym_menu
else
    en_new_nym_menu
fi

echo 'still here'
echo "running script"