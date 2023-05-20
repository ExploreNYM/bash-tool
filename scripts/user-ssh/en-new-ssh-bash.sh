#!/bin/bash
function cleanup {
    rm "$BASH_SOURCE"
    unset sshkey_filename
    unset public_key
    unset permission
    shift 1
}
trap cleanup RETURN
clear && echo -e "" && echo -e "" && echo -e " _____            _                _   ___   ____  __ " && echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" && echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" && echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m                                       " && echo -e "" \
&& echo -e '\033[1mScript Contents:\033[22m' && echo && echo '  • Create new ssh-key' && echo '  • Copy public ssh-key to your server' && echo '  • Test ssh-key login' && echo \
&& read -p "Do you want to continue? (Y/n) " permission
if [[ "$permission" == "Y" || "$permission" == "" ]]; then
cd ~/.ssh/ 2> /dev/null \
sshkey_filename=""
while [[ -z "$sshkey_filename" ]]; do
    read -p "Enter SSH key filename: " sshkey_filename
done
ssh-keygen -f $sshkey_filename 2> /dev/null \
&& ssh-add $sshkey_filename 2> /dev/null \
&& public_key="$sshkey_filename.pub" \
&& echo "Copying $public_key to your server" \
&& ssh-copy-id -i ~/.ssh/$public_key $1 2> /dev/null \
&& echo "Testing connect via ssh key" \
&& ssh $1@$2 \
&& sleep 1 \
&& wget -O en-ssh-secure.sh https://github.com/ExploreNYM/bash-tool/raw/main/scripts/user-ssh/en-ssh-secure.sh && chmod +x en-ssh-secure.sh && . ~/en-ssh-secure.sh \
|| echo error
exit
else
    echo "Exiting Script."
    return
fi
return