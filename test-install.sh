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
REPO_URL="https://github.com/KarlAvec1K/Anet_ET4/archive/refs/heads/jschuh-configs.zip"
ZIP_FILE="Anet_ET4.zip"
DESTINATION_FOLDER="/home/pi/test/"
KLIPPER_CONFIGS_FOLDER="$DESTINATION_FOLDER/klipper-configs/"

# Step 1: Download the repository zip file from the schuh-configs branch
curl -L $REPO_URL -o $ZIP_FILE

# Step 2: Unzip the downloaded file
unzip $ZIP_FILE

# Step 3: Move the .cfg files from Anet_ET4_Config_files to the destination folder, overwriting if they exist
UNZIPPED_FOLDER=$(unzip -Z1 $ZIP_FILE | head -n 1 | cut -f1 -d "/")
CONFIG_FOLDER="$UNZIPPED_FOLDER/Anet_ET4_Config_files"
mkdir -p $DESTINATION_FOLDER
mv -f $CONFIG_FOLDER/*.cfg $DESTINATION_FOLDER

# Step 4: Move the klipper-configs folder to the destination folder, overwriting if it exists
KLIPPER_CONFIGS_SRC="$UNZIPPED_FOLDER/klipper-configs"
mkdir -p $KLIPPER_CONFIGS_FOLDER
mv -f $KLIPPER_CONFIGS_SRC/*.cfg $KLIPPER_CONFIGS_FOLDER

# Step 5: Clean up
rm -rf $ZIP_FILE $UNZIPPED_FOLDER

# Optional: Delete the script itself if running from a local script
# rm -- "$0"

echo "Installation completed successfully."
