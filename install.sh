#!/bin/bash

# Spinner function for loading bar
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
LOCAL_REPO_FOLDER="/home/pi/Anet_ET4"
LOCAL_REPO_CONFIG_FOLDER="$LOCAL_REPO_FOLDER/Anet_ET4_Config_files"

# Function to get checksums
get_checksums() {
    local dir=$1
    find $dir -type f -name '*.cfg' -exec md5sum {} \; | sort -k 2 > "$dir/checksums.txt"
}

# Function to copy updated files
copy_updated_files() {
    local src=$1
    local dest=$2
    local checksums_src="$src/checksums.txt"
    local checksums_dest="$dest/checksums.txt"
    local updated_count=0
    local installed_count=0

    # Get checksums
    get_checksums $src
    if [ -f $checksums_dest ]; then
        # Compare checksums and copy updated files
        while read -r checksum file; do
            local relative_file="${file#$src/}"
            local dest_file="$dest/$relative_file"
            if ! grep -q "$relative_file" "$checksums_dest"; then
                local dir=$(dirname "$dest_file")
                mkdir -p "$dir"
                cp -f "$file" "$dest_file"
                ((installed_count++))
            else
                local dest_checksum=$(grep "$relative_file" "$checksums_dest" | awk '{print $1}')
                if [ "$checksum" != "$dest_checksum" ]; then
                    local dir=$(dirname "$dest_file")
                    mkdir -p "$dir"
                    cp -f "$file" "$dest_file"
                    ((updated_count++))
                fi
            fi
        done < "$checksums_src"
    else
        # If no checksum file exists, copy all files
        find $src -name '*.cfg' | while read -r file; do
            local relative_file="${file#$src/}"
            local dest_file="$dest/$relative_file"
            local dir=$(dirname "$dest_file")
            mkdir -p "$dir"
            cp -f "$file" "$dest_file"
            ((installed_count++))
        done
    fi

    # Output results
    if [ $updated_count -gt 0 ] || [ $installed_count -gt 0 ]; then
        echo "Files updated: $updated_count"
        echo "Files installed: $installed_count"
    fi
}

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

# Step 2: Check and Create necessary directories if not exist
echo "Checking and creating necessary directories..."
[ ! -d $DESTINATION_FOLDER ] && mkdir -p $DESTINATION_FOLDER
[ ! -d $KLIPPER_CONFIGS_FOLDER ] && mkdir -p $KLIPPER_CONFIGS_FOLDER
[ ! -d $KLIPPER_MACROS_FOLDER ] && mkdir -p $KLIPPER_MACROS_FOLDER
[ ! -d $OPTIONAL_MACROS_FOLDER ] && mkdir -p $OPTIONAL_MACROS_FOLDER

# Step 3: Copy updated files with loading bar
echo "Copying configuration files..."
(
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER $DESTINATION_FOLDER
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER/klipper-configs $KLIPPER_CONFIGS_FOLDER
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER/klipper-macros $KLIPPER_MACROS_FOLDER
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER/klipper-macros/optional $OPTIONAL_MACROS_FOLDER
) & spinner

# Step 4: Clean up
echo "Cleaning up..."
wait
echo "Update/installation completed successfully."
