#!/bin/bash



mixnodes_old() {
    echo "Performing actions for mixnodes..."
    # Add your mixnodes logic here
}


gateways_old() {
    echo "Performing actions for gateways..."
    # Add your gateways logic here
}


net_requesters_old() {
    echo "Performing actions for net-requesters..."
    # Add your net-requesters logic here
}
#### Function for nym folders found ####
########################################

#--------------------------------------#

########################################
#### Function for nym folders found ####

mixnodes_new() {
    echo "Performing actions for mixnodes..."
    # Add your mixnodes logic here
}


gateways_new() {
    echo "Performing actions for gateways..."
    # Add your gateways logic here
}


net_requesters_new() {
    echo "Performing actions for net-requesters..."
    # Add your net-requesters logic here
}

#### Function for nym folders found ####
########################################



# Search for .nym folder
nym_folder=$(find / -type d -name ".nym" 2>/dev/null)

# Check if .nym folder is found
if [ -z "$nym_folder" ]; then
    echo "Could not find .nym folder."
    exit 1
fi

echo "Found .nym folder: $nym_folder"

# Read the contents of .nym folder
folder_contents=$(ls "$nym_folder")

# Check if .nym folder is empty
if [ -z "$folder_contents" ]; then
    echo "No folders found inside .nym."
    exit 1
fi

# Create a selection menu
PS3="Select a folder: "
select folder_name in $folder_contents; do
    if [ -n "$folder_name" ]; then
        echo "Selected folder: $folder_name"
        break
    else
        echo "Invalid selection. Try again."
    fi
done

# Perform actions based on the selected folder
case "$folder_name" in
    mixnodes)
        mixnodes
        ;;
    gateways)
        gateways
        ;;
    net-requesters)
        net_requesters
        ;;
    *)
        echo "Invalid folder selected."
        exit 1
        ;;
esac

exit 0
