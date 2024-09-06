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
echo "                                                                                "
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@%######&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@######%&@@@"
echo "@@@@%%%%######@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#######%%%&@@@"
echo "@@@@%%%%%%#######@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@######%%%%%%&@@@"
echo "@@@@%%%%%%%%%######@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#######%%%%%%%%&@@@"
echo "@@@@%%%%%%%%%%%#######@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@######%%%%%%%%%%%&@@@"
echo "@@@@%%%%%%%%%%%%%%######@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#######%%%%%%%%%%%%%&@@@"
echo "@@@@@%%%%%%%%%%%%%%%#######@@@@@@@@@@@@@@@@@@@@@@@@@@@######%%%%%%%%%%%%%%%@@@@@"
echo "@@@@@@@@%%%%%%%%%%%%%%%######@@@@@@@@@@@@@@@@@@@@@@&######%%%%%%%%%%%%%%@@@@@@@@"
echo "@@@@@@@@@@@%%%%%%%%%%%%%%#######@@@@@@@@@@@@@@@@@######%%%%%%%%%%%%%%%@@@@@@@@@@"
echo "@@@@@@@@@@@@@%%%%%%%%%%%%%%%######@@@@@@@@@@@@@######%%%%%%%%%%%%%%@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%#######@@@@@@@######%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%######@@@######%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%#########%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%%%%#####%%%%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%%%#####%%%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%%%%%%%%%#####%%%%%%%%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@%%%@@@@@%%%##@@%%%@@@#################@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@%%%@@@%%%#@@@@@%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@%%%#%%##@@@@@@@%%%@@@%%%@@@%%%%%%%%@@@@@%%%%%%%%@@@@@%%%%%%%@@@@%%%%%%%@@@@"
echo "@@@@@%%%@%%#@@@@@@@@%%%@@@%%%@@@%%&@@@@%%%@@@%%@@@@&%%@@&%%@@@@@%%@@@%%%@@@@@@@@"
echo "@@@@@%%%@@%%%##@@@@@%%%@@@%%%@@@%%&@@@@%%%@@@%%@@@@@%%@@%%%%%%%%%%@@@%%%@@@@@@@@"
echo "@@@@@%%%@@@@@%%##@@@%%%@@@%%%@@@%%%@@@%%%@@@@%%%@@%%%%@@@%%%%@@@%@@@@%%%@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%&@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%&@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "                                                                                "

# Variables
REPO_URL="https://github.com/KarlAvec1K/Anet_ET4.git"
REPO_BRANCH="main"
DESTINATION_FOLDER="/home/pi/printer_data/config"
KLIPPER_CONFIGS_FOLDER="$DESTINATION_FOLDER/klipper-configs"
KLIPPER_MACROS_FOLDER="$DESTINATION_FOLDER/klipper-macros"
OPTIONAL_MACROS_FOLDER="$KLIPPER_MACROS_FOLDER/optional"
LOCAL_REPO_FOLDER="/home/pi/Anet_ET4"
LOCAL_REPO_CONFIG_FOLDER="$LOCAL_REPO_FOLDER/Anet_ET4_Config_files"
VERBOSE=false
BACKUP=false

# Function for error handling
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Help menu
print_help() {
    echo "Usage: install.sh [options]"
    echo
    echo "Options:"
    echo "  -v, --verbose      Enable verbose output"
    echo "  -b, --backup       Backup existing configuration files before installation"
    echo "  -h, --help         Show this help menu"
    exit 0
}

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

# Backup existing config files
backup_existing_files() {
    local dir=$1
    local backup_dir="$dir/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p $backup_dir
    find $dir -name '*.cfg' -exec mv {} $backup_dir/ \;
    echo "Backup of existing configuration files created at $backup_dir."
}

# Parse arguments
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -v | --verbose )
    VERBOSE=true
    ;;
  -b | --backup )
    BACKUP=true
    ;;
  -h | --help )
    print_help
    ;;
esac; shift; done

# Step 1: Clone or Pull Repository
echo "Fetching repository..."
if [ ! -d "$LOCAL_REPO_FOLDER" ]; then
    if $VERBOSE; then
        git clone -v -b $REPO_BRANCH $REPO_URL $LOCAL_REPO_FOLDER || error_exit "Failed to clone repository."
    else
        git clone -b $REPO_BRANCH $REPO_URL $LOCAL_REPO_FOLDER & spinner || error_exit "Failed to clone repository."
    fi
else
    cd $LOCAL_REPO_FOLDER || error_exit "Failed to navigate to local repository."
    git config pull.ff only || error_exit "Failed to set git pull strategy."
    if $VERBOSE; then
        git pull origin $REPO_BRANCH || error_exit "Failed to pull updates."
    else
        git pull origin $REPO_BRANCH & spinner || error_exit "Failed to pull updates."
    fi
fi

# Step 2: Check and Create necessary directories if not exist
[ ! -d $DESTINATION_FOLDER ] && mkdir -p $DESTINATION_FOLDER
[ ! -d $KLIPPER_CONFIGS_FOLDER ] && mkdir -p $KLIPPER_CONFIGS_FOLDER
[ ! -d $KLIPPER_MACROS_FOLDER ] && mkdir -p $KLIPPER_MACROS_FOLDER
[ ! -d $OPTIONAL_MACROS_FOLDER ] && mkdir -p $OPTIONAL_MACROS_FOLDER

# Step 3: Backup if requested
if $BACKUP; then
    echo "Backing up existing files..."
    backup_existing_files $DESTINATION_FOLDER
fi

# Step 4: Copy updated files
(
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER $DESTINATION_FOLDER
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER/klipper-configs $KLIPPER_CONFIGS_FOLDER
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER/klipper-macros $KLIPPER_MACROS_FOLDER
    copy_updated_files $LOCAL_REPO_CONFIG_FOLDER/klipper-macros/optional $OPTIONAL_MACROS_FOLDER
) & spinner

# Step 5: Done
echo "Update/installation completed successfully."
