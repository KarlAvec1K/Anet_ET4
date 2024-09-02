#!/bin/bash

# Variables
REPO_URL="https://github.com/KarlAvec1K/Anet_ET4/archive/refs/heads/main.zip"
ZIP_FILE="Anet_ET4.zip"
DESTINATION_FOLDER="/home/pi/test/"

# Step 1: Download the repository zip file
curl -L $REPO_URL -o $ZIP_FILE

# Step 2: Unzip the downloaded file
unzip $ZIP_FILE

# Step 3: Move the .cfg files to the destination folder
UNZIPPED_FOLDER=$(unzip -Z1 $ZIP_FILE | head -n 1 | cut -f1 -d "/")
CONFIG_FOLDER="$UNZIPPED_FOLDER/Anet_ET4_Config_files"
mkdir -p $DESTINATION_FOLDER
mv $CONFIG_FOLDER/*.cfg $DESTINATION_FOLDER

# Step 4: Clean up
rm -rf $ZIP_FILE $UNZIPPED_FOLDER

# Optional: Delete the script itself if running from a local script
# rm -- "$0"

echo "Installation completed successfully."
