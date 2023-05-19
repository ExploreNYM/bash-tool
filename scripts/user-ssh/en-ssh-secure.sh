#!/bin/bash
function cleanup {
    rm "$BASH_SOURCE"
    unset sshd_config
    unset permission
}
trap cleanup RETURN
clear && echo -e "" && echo -e "" && echo -e " _____            _                _   ___   ____  __ " && echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" && echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" && echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m                                       " && echo -e "" \
&& echo -e '\033[1mScript Contents:\033[22m' && echo && echo '  • Disable root login' && echo '  • Disable password login' && echo \
&& read -p "Do you want to continue? (Y/n) " permission
if [[ "$permission" == "Y" || "$permission" == "" ]]; then
    sshd_config="/etc/ssh/sshd_config" 2> /dev/null \
    && sudo sed -i 's/^PermitRootLogin.*$/PermitRootLogin no/' $sshd_config 2> /dev/null \
    && sudo sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication no/' $sshd_config 2> /dev/null \
    && sudo systemctl restart sshd 2> /dev/null \
    || echo error
    return
else
    echo "Exiting Script."
    return
fi
return