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
DESTINATION_FOLDER="/home/pi/printer_data/config/"
KLIPPER_CONFIGS_FOLDER="$DESTINATION_FOLDER/klipper-configs/"
KLIPPER_MACROS_FOLDER="$DESTINATION_FOLDER/klipper-macros/"
OPTIONAL_MACROS_FOLDER="$KLIPPER_MACROS_FOLDER/optional/"

# Step 1: Download the repository zip file from the jschuh-configs branch
curl -L $REPO_URL -o $ZIP_FILE

# Step 2: Unzip the downloaded file
unzip $ZIP_FILE

# Step 3: Move the printer.cfg file to the destination folder, overwriting if it exists
UNZIPPED_FOLDER=$(unzip -Z1 $ZIP_FILE | head -n 1 | cut -f1 -d "/")
CONFIG_FOLDER="$UNZIPPED_FOLDER/Anet_ET4_Config_files"
mv -f $CONFIG_FOLDER/printer.cfg $DESTINATION_FOLDER

# Step 4: Move the klipper-configs folder and its .cfg files to the destination folder, overwriting if they exist
mkdir -p $KLIPPER_CONFIGS_FOLDER
mv -f $CONFIG_FOLDER/klipper-configs/*.cfg $KLIPPER_CONFIGS_FOLDER

# Step 5: Move the klipper-macros folder and its .cfg files to the destination folder, overwriting if they exist
mkdir -p $KLIPPER_MACROS_FOLDER
mv -f $CONFIG_FOLDER/klipper-macros/*.cfg $KLIPPER_MACROS_FOLDER

# Step 6: Handle the 'optional' subfolder inside 'klipper-macros', keeping its structure
mkdir -p $OPTIONAL_MACROS_FOLDER
mv -f $CONFIG_FOLDER/klipper-macros/optional/*.cfg $OPTIONAL_MACROS_FOLDER

# Step 7: Clean up
rm -rf $ZIP_FILE $UNZIPPED_FOLDER

# Optional: Delete the script itself if running from a local script
# rm -- "$0"

echo "Installation completed successfully."
