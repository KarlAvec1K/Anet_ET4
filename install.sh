#!/bin/bash

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
DESTINATION_FOLDER="/home/pi/printer_data/config/"
KLIPPER_CONFIGS_FOLDER="$DESTINATION_FOLDER/klipper-configs/"
KLIPPER_MACROS_FOLDER="$DESTINATION_FOLDER/klipper-macros/"
OPTIONAL_MACROS_FOLDER="$KLIPPER_MACROS_FOLDER/optional/"
LOCAL_REPO_FOLDER="/home/pi/Anet_ET4_Config_files/"

# Step 1: Check if the local repo folder exists
if [ ! -d "$LOCAL_REPO_FOLDER" ]; then
    # Clone the repository if it doesn't exist
    git clone -b $REPO_BRANCH $REPO_URL $LOCAL_REPO_FOLDER
else
    # Pull the latest changes if the folder exists
    cd $LOCAL_REPO_FOLDER
    git pull origin $REPO_BRANCH
fi

# Step 2: Move the printer.cfg file to the destination folder, overwriting if it exists
mv -f $LOCAL_REPO_FOLDER/printer.cfg $DESTINATION_FOLDER

# Step 3: Move the klipper-configs folder and its .cfg files to the destination folder, overwriting if they exist
mkdir -p $KLIPPER_CONFIGS_FOLDER
mv -f $LOCAL_REPO_FOLDER/klipper-configs/*.cfg $KLIPPER_CONFIGS_FOLDER

# Step 4: Move the klipper-macros folder and its .cfg files to the destination folder, overwriting if they exist
mkdir -p $KLIPPER_MACROS_FOLDER
mv -f $LOCAL_REPO_FOLDER/klipper-macros/*.cfg $KLIPPER_MACROS_FOLDER

# Step 5: Handle the 'optional' subfolder inside 'klipper-macros', keeping its structure
mkdir -p $OPTIONAL_MACROS_FOLDER
mv -f $LOCAL_REPO_FOLDER/klipper-macros/optional/*.cfg $OPTIONAL_MACROS_FOLDER

# Optional: Clean up
echo "Update/installation completed successfully."
