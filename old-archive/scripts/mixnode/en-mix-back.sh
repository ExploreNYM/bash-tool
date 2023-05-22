#!/bin/bash
function cleanup {
    rm "$BASH_SOURCE"
    unset latest_release
    unset mixnode_url
    unset wallet
}
trap cleanup RETURN
clear && echo && echo && echo " _____            _                _   ___   ____  __ " \
&& echo -e "| ____|_  ___ __ | | ___  _ __ ___| \ | \ \ / /  \/  |" && echo -e "|  _| \ \/ / '_ \| |/ _ \| '__/ _ \  \| |\ V /| |\/| |" \
&& echo -e "| |___ >  <| |_) | | (_) | | |  __/ |\  | | | | |  | |" && echo -e "|_____/_/\_\ .__/|_|\___/|_|  \___|_| \_| |_| |_|  |_|" \
&& echo -e "           |_| \033[4mhttps://explorenym.net/official-links\033[0m" && echo
echo -e '\033[1mPreparing nym-mixnode backup script\033[22m' && echo
# Look for mixnode directory and set variable $mixnode_dir
mixnodes_dir=$(find / -type d -name mixnodes 2>/dev/null | grep '/\.nym/mixnodes$')

# -z is false not -n is true
if [ -z "$mixnodes_dir" ]; then
  echo "Error: /.nym/mixnodes directory not found."
  return
fi

# Get the folder name within the mixnodes directory
folder_name=$(find "$mixnodes_dir" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" | head -n1)

# Check if a folder was found
if [ -z "$folder_name" ]; then
  echo "No folder found in $mixnodes_dir"
  return
else
  echo "nym-mixnode found : $folder_name"

fi

pub_host=$(curl ifconfig.me)

echo "Now copy this script and paste it in your local terminal to pull a backup of your mixnode."
echo 
echo "scp -r $USER@$pub_host:$mixnodes_dir/$folder_name ~/$folder_name"
echo 
return