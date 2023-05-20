#!/bin/bash
function cleanup {
    rm "$BASH_SOURCE"
    unset new_password
    unset new_user
    unset public_ip
    unset permission
    unset permission_ssh
    unset choice
}
trap cleanup RETURN
clear && echo -e "" && echo -e "" && echo -e " _____            _                _   ___   ____  __ " && echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" && echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" && echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m                                       " && echo -e "" \
&& echo -e '\033[1mScript Contents:\033[22m' && echo && echo '  • Create new user' && echo '  • Give sudo group privileges' && echo '  • Prepare ssh-key script (optional)' && echo \
&& read -p "Do you want to continue? (Y/n) " permission
if [[ "$permission" == "Y" || "$permission" == "y" || "$permission" == "" ]]; then
    [ "$(id -u)" != "0" ] && echo "This script must be run as root" && return
    while [[ -z "$new_user" ]]; do
    read -p "Enter new username: " new_user
    done
    sudo adduser --gecos GECOS  $new_user || return

    

usermod -aG sudo $new_user 2> /dev/null \
&& read -p "Do you want to create ssh-key? (Y/n) " permission_ssh
if [[ "$permission_ssh" == "Y" || "$permission_ssh" == "y" || "$permission_ssh" == "" ]]; then
public_ip="$(curl ifconfig.me 2>/dev/null)"

while true; do
    echo -e '\033[1mSelect Option:\033[22m' && echo
    echo "1. MAC/LINUX (Bash)"
    echo "2. Powershell (Windows)"
    echo -e "3. Quit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            echo "Paste this code in your local terminal:"
            echo
            echo "wget -q -O en-new-ssh-bash.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/user-ssh/en-new-ssh-bash.sh && chmod +x en-new-ssh-bash.sh && . ~/en-new-ssh-bash.sh $new_user@$public_ip"
            return
            ;;
        2)
            echo "Paste this code in your local Powershell:"
            echo
            echo "Invoke-WebRequest \"https://github.com/ExploreNYM/bash-tool/raw/main/scripts/user-ssh/en-new-ssh-shell.ps1\" -OutFile \"en-new-ssh-shell.ps1\"
            Set-ExecutionPolicy -Scope CurrentUser Unrestricted -Force
            .\en-new-ssh-shell.ps1  -arg1 \"$new_user@$public_ip\""


            return
            ;;
        3)
            #quit
            return
            ;;
        *)
            echo -e "\xE2\x9C\x97 Invalid option, please try again."
            ;;
    esac
done


else

  sudo -u "$new_user" bash -c 'cd ~ && exec bash' > /dev/null 2
  #add mixnode menu
    return
fi
else
    echo "Exiting Script."
    return
fi
return