#!/bin/bash

#Font formats
set_bold="\033[1m"
set_normal="\033[22m"

##############################
## MAIN EXECUTION OF SCRIPT ##
##############################

../display-logo.sh
echo -e "${set_bold}Mixnode current status Status press [q] to exit.\n$set_normal"
sudo systemctl status nym-mixnode
