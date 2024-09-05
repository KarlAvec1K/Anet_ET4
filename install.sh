#!/bin/bash

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Display ASCII logo
echo "           _   _ ______ _______    ______ _______ _  _   "
echo "     /\   | \ | |  ____|__   __|  |  ____|__   __| || |  "
echo "    /  \  |  \| | |__     | |     | |__     | |  | || |_ "
echo "   / /\ \ | . \` |  __|    | |     |  __|    | |  |__   _|"
echo "  / ____ \| |\  | |____   | |     | |____   | |     | |  "
echo " /_/    \_\_| \_|______|  |_|     |______|  |_|     |_|  "
echo "                                                         "
echo "                                                         "

# Variables
REPO_URL="https://github.com/KarlAvec1K/Anet_ET4.git"
REPO_BRANCH="jschuh-configs"
DESTINATION_FOLDER="/home/pi/printer_data/config"
KLIPPER_CONFIGS_FOLDER="$DESTINATION_FOLDER/klipper-configs"
KLIPPER_MACROS_FOLDER="$DESTINATION_FOLDER/klipper-macros"
OPTIONAL_MACROS_FOLDER="$KLIPPER_MACROS_FOLDER/optional"
LOCAL_REPO_FOLDER="/home/pi/Anet_ET4_Config_files"

# Step 1: Clone or Pull Repository
echo "Fetching repository..."
if [ ! -d "$LOCAL_REPO_FOLDER" ]; then
    git clone -b $REPO_BRANCH $REPO_URL $LOCAL_REPO_FOLDER & spinner
else
    cd $LOCAL_REPO_FOLDER
    git pull origin $REPO_BRANCH & spinner
fi

# Step 2: Move files (check existence first)
echo "Moving configuration files..."

if [ -f "$LOCAL_REPO_FOLDER/printer.cfg" ]; then
    mv -f $LOCAL_REPO_FOLDER/printer.cfg $DESTINATION_FOLDER
else
    echo "Warning: printer.cfg not found in $LOCAL_REPO_FOLDER"
fi

mkdir -p $KLIPPER_CONFIGS_FOLDER
mv -f $LOCAL_REPO_FOLDER/klipper-configs/*.cfg $KLIPPER_CONFIGS_FOLDER

mkdir -p $KLIPPER_MACROS_FOLDER
mv -f $LOCAL_REPO_FOLDER/klipper-macros/*.cfg $KLIPPER_MACROS_FOLDER

mkdir -p $OPTIONAL_MACROS_FOLDER
mv -f $LOCAL_REPO_FOLDER/klipper-macros/optional/*.cfg $OPTIONAL_MACROS_FOLDER

# Step 3: Clean up
echo "Cleaning up..."
wait
echo "Update/installation completed successfully."
