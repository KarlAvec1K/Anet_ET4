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
    git config pull.ff only   # Set fast-forward only strategy
    git pull origin $REPO_BRANCH & spinner
fi

# Debugging: List contents of the local repository folder
echo "Listing contents of $LOCAL_REPO_FOLDER:"
ls -la $LOCAL_REPO_FOLDER

# Step 2: Create necessary directories
echo "Creating necessary directories..."
mkdir -p $DESTINATION_FOLDER
mkdir -p $KLIPPER_CONFIGS_FOLDER
mkdir -p $KLIPPER_MACROS_FOLDER
mkdir -p $OPTIONAL_MACROS_FOLDER

# Step 3: Move files
echo "Moving configuration files..."
echo "Moving .cfg files from $LOCAL_REPO_FOLDER to $DESTINATION_FOLDER"
find $LOCAL_REPO_FOLDER -maxdepth 1 -name '*.cfg' -exec mv -f {} $DESTINATION_FOLDER/ \;

echo "Moving .cfg files from $LOCAL_REPO_FOLDER/klipper-configs to $KLIPPER_CONFIGS_FOLDER"
find $LOCAL_REPO_FOLDER/klipper-configs -name '*.cfg' -exec mv -f {} $KLIPPER_CONFIGS_FOLDER/ \;

echo "Moving .cfg files from $LOCAL_REPO_FOLDER/klipper-macros to $KLIPPER_MACROS_FOLDER"
find $LOCAL_REPO_FOLDER/klipper-macros -name '*.cfg' -exec mv -f {} $KLIPPER_MACROS_FOLDER/ \;

echo "Moving .cfg files from $LOCAL_REPO_FOLDER/klipper-macros/optional to $OPTIONAL_MACROS_FOLDER"
find $LOCAL_REPO_FOLDER/klipper-macros/optional -name '*.cfg' -exec mv -f {} $OPTIONAL_MACROS_FOLDER/ \;

# Step 4: Clean up
echo "Cleaning up..."
wait
echo "Update/installation completed successfully."
