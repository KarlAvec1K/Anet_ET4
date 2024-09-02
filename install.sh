#!/bin/bash

# Display ASCII logo
echo "   _  __          _                      __ _      "
echo "  | |/ /         | |   /\               /_ | |     "
echo "  | ' / __ _ _ __| |  /  \__   _____  ___| | | __  "
echo "  |  < / _\` | '__| | / /\ \ \ / / _ \/ __| | |/ /  "
echo "  | . \ (_| | |  | |/ ____ \ V /  __/ (__| |   <   "
echo "  |_|\_\__,_|_|  |_/_/    \_\_/ \___|\___|_|_|\_\  "
echo "                                                         "
echo "  https://github.com/KarlAvec1K/anet-et4"
echo "                                                         "
echo "           _   _ ______ _______    ______ _______ _  _   "
echo "     /\   | \ | |  ____|__   __|  |  ____|__   __| || |  "
echo "    /  \  |  \| | |__     | |     | |__     | |  | || |_ "
echo "   / /\ \ | . \` |  __|    | |     |  __|    | |  |__   _|"
echo "  / ____ \| |\  | |____   | |     | |____   | |     | |  "
echo " /_/    \_\_| \_|______|  |_|     |______|  |_|     |_|  "
echo "                                                         " 

# Variables
REPO_URL="https://github.com/KarlAvec1K/Anet_ET4/archive/refs/heads/main.zip"
ZIP_FILE="Anet_ET4.zip"
DESTINATION_FOLDER="/home/pi/printer_data/config/"

# Step 1: Download the repository zip file
curl -L $REPO_URL -o $ZIP_FILE

# Step 2: Unzip the downloaded file
unzip $ZIP_FILE

# Step 3: Move the .cfg files to the destination folder, overwriting if they exist
UNZIPPED_FOLDER=$(unzip -Z1 $ZIP_FILE | head -n 1 | cut -f1 -d "/")
CONFIG_FOLDER="$UNZIPPED_FOLDER/Anet_ET4_Config_files"
mkdir -p $DESTINATION_FOLDER
mv -f $CONFIG_FOLDER/*.cfg $DESTINATION_FOLDER

# Step 4: Clean up
rm -rf $ZIP_FILE $UNZIPPED_FOLDER

# Optional: Delete the script itself if running from a local script
# rm -- "$0"

echo "Installation completed successfully."
