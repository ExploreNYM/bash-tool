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
				./install-mixnode.sh && exit
			    ;;
			2)
				./migrate-mixnode.sh && exit
				;;
			3)
				exit
				;;
			*)
				echo
				echo -e "$fail_x Invalid option, please try again."
				;;
		esac
	done
}

function cleanup {
    sudo rm "$HOME/en-mixnode.sh" > /dev/null 2>&1
    sudo rm "/root/en-mixnode.sh" > /dev/null 2>&1
    sudo rm "$HOME/ne-output.txt" > /dev/null 2>&1
    unset variables
}
trap cleanup exit

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

./display-logo.sh
./check-vps.sh || exit

#set mixnode
nym_binary_name="nym-mixnode" #don't know what this is for yet


# Latest release
nym_release=$(curl -s "https://github.com/nymtech/nym/releases/" | grep -oEm 1 "nym-binaries-v[0-9]+\.[0-9]+\.[0-9]+")
nym_release_url="https://github.com/nymtech/nym/releases/download/$nym_release"

nym_migrate="incomplete"
until [ "$nym_migrate" == "complete" ]; do

# Check for .nym folder
nym_path=$(find / -type d -name ".nym" 2>/dev/null)


if [ -n "$nym_path" ]; then
    echo -e "\xE2\x9C\x93 NYM folder found."


# Find config file
node_path="$nym_path/mixnodes"

    nym_node_id=$(find "$node_path" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | head -n1)

    nym_config_file=$node_path/$nym_node_id/config/config.toml

    if ! [ -f "$nym_config_file" ]; then
    echo "Cant find config.toml"
    exit 1
    fi


# variables from config
wallet_address=$(grep "wallet_address" "$nym_config_file" | awk -F "'" '{print $2}')
nym_version=$(grep "version" "$nym_config_file" | awk -F "'" '{print $2}')



# say current version
echo
echo "nym-mixnode current version $nym_version"


# Menu for update or back-up
while true; do
    echo
    echo -e "\033[1m nym-mixnode menu:\033[22m" && echo
    echo "1. Update nym-mixnode"
    echo "2. Backup nym-mixnode"
    echo "3. Change mixnode details (name/description/link/location)"
    echo "4. Check nym-mixnode status"
    echo "5. Quit"
    read -p "Enter your choice: " old_nym_menu_choice

    case $old_nym_menu_choice in
        1)
            en_logo_display
    
            echo -e '\033[1mMixnode Update Started.\033[22m' && echo

            sudo systemctl stop nym-mixnode
            # Download latest binary
            
            wget -q -O $nym_binary_name "$nym_release_url/$nym_binary_name"
            
            sudo chmod u+x $nym_binary_name
            
            sudo mv $nym_binary_name /usr/local/bin/
           
            # Init new binary
            nym-mixnode init --id $nym_node_id --host $bind_ip --announce-host $announce_ip --wallet-address $wallet_address  > ne-output.txt

            # check system ctl is running from /usr/local/bin/
            file_path="/etc/systemd/system/nym-mixnode.service"
            if [ -f "$file_path" ]; then

                sudo chown -R $USER:$USER /etc/systemd/system/nym-mixnode.service
                user_search_pattern="User="
                user_replace_line="User=$USER"
                sudo sed -i "/$user_search_pattern/c $user_replace_line" "/etc/systemd/system/nym-mixnode.service"
                sudo systemctl daemon-reload
                search_pattern="ExecStart="
                replace_line="ExecStart=/usr/local/bin/nym-mixnode run --id $nym_node_id"
                sudo sed -i "/$search_pattern/c $replace_line" "/etc/systemd/system/nym-mixnode.service"
                sudo systemctl daemon-reload
                
                echo "Line replaced successfully."
            else
                echo "File does not exist."
                echo "Storage=persistent" | sudo tee /etc/systemd/journald.conf >/dev/null
            sudo systemctl restart systemd-journald

            sudo tee /etc/systemd/system/nym-mixnode.service >/dev/null <<EOF
            [Unit]
            Description=Nym Mixnode

            [Service]
            User=$USER
            ExecStart=/usr/local/bin/nym-mixnode run --id $nym_node_id
            KillSignal=SIGINT
            Restart=on-failure
            RestartSec=30
            StartLimitInterval=350
            StartLimitBurst=10
            LimitNOFILE=65535

            [Install]
            WantedBy=multi-user.target
EOF


            sudo sh -c 'echo "DefaultLimitNOFILE=65535" >> /etc/systemd/system.conf'

            
            fi


            sudo systemctl restart nym-mixnode

            

            nym_version=$(grep "version" "$nym_config_file" | awk -F "'" '{print $2}')

            if [[ `service nym-mixnode status | grep active` =~ "running" ]]; then

                
                en_logo_display
                sleep 1
                echo -e "\033[1mMixnode updated to version: $nym_version and running, remember update the version in your wallet!.\033[22m" && echo
                echo
                sleep 2
                sudo systemctl status nym-mixnode --no-pager
                echo
                echo
                echo -e "Server Restart Initiated, Mixnode updated and running cya next update :)"
                sudo reboot
            else
            echo -e "nym-mixnode was not updated correctly, please re-update."
            fi

            exit
            ;;
        2)
            # BACKUP SECTION
            en_logo_display
    
            echo -e '\033[1mMixnode Backup Started.\033[22m' && echo
            echo "Copy this script and paste it in your local terminal(mac) shell(windows) to pull a backup of your mixnode."
            echo 
            echo "scp -r $USER@$announce_ip:$node_path/$nym_node_id/ ~/$nym_node_id"
            echo 
            exit
            ;;
        3)
            en_logo_display
    
            

            echo -e '\033[1mUpdating description of your mixnode.\033[22m' && echo

            nym-mixnode describe --id $nym_node_id

            sudo systemctl restart nym-mixnode

            if [[ `service nym-mixnode status | grep active` =~ "running" ]]; then
            echo
            echo "Description updated successfully"
            else
            echo
            echo 'error: mixnode not running'
            fi


            ;;

        4)
            en_logo_display
    
            echo -e '\033[1mMixnode current status Status press [q] to exit.\033[22m' && echo
            sudo systemctl status nym-mixnode
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

#updated ended

else
	# Install / migrate menu
	no_nym_folder_menu
fi

done
