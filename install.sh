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
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@  https://github.com/KarlAvec1K/Anet_ET4.git  @@@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@  https://github.com/jschuh/klipper-macros.git  @@@@@@@@@@@@@@@@@@"
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

# Variables
REPO_URL="https://github.com/KarlAvec1K/Anet_ET4.git"
REPO_BRANCH="main"
DESTINATION_FOLDER="/home/pi/printer_data/config"
KLIPPER_CONFIGS_FOLDER="$DESTINATION_FOLDER/klipper-configs"
KLIPPER_MACROS_FOLDER="$DESTINATION_FOLDER/klipper-macros"
OPTIONAL_MACROS_FOLDER="$KLIPPER_MACROS_FOLDER/optional"
LOCAL_REPO_FOLDER="/home/pi/Anet_ET4"
LOCAL_REPO_CONFIG_FOLDER="$LOCAL_REPO_FOLDER/Anet_ET4_Config_files"
KLIPPER_MACROS_REPO_URL="https://github.com/KarlAvec1K/klipper-macros.git"
KLIPPER_MACROS_REPO_BRANCH="main"

# Function to get checksums
get_checksums() {
    local dir=$1
    if [ -d "$dir" ]; then
        find "$dir" -type f -name '*.cfg' -exec md5sum {} \; | sort -k 2 > "$dir/checksums.txt"
    else
        echo "Directory $dir does not exist. Skipping checksum generation."
    fi
}

# Function to copy updated files
copy_updated_files() {
    local src=$1
    local dest=$2
    local checksums_src="$src/checksums.txt"
    local checksums_dest="$dest/checksums.txt"
    local updated_count=0
    local installed_count=0

    echo "Source directory for copying: $src"
    echo "Destination directory: $dest"

    if [ -d "$src" ]; then
        # Get checksums
        get_checksums "$src"
        if [ -f "$checksums_dest" ]; then
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
            find "$src" -name '*.cfg' | while read -r file; do
                local relative_file="${file#$src/}"
                local dest_file="$dest/$relative_file"
                local dir=$(dirname "$dest_file")
                mkdir -p "$dir"
                cp -f "$file" "$dest_file"
                ((installed_count++))
            done
        fi
    else
        echo "Source directory $src does not exist. Skipping file copy."
    fi

    # Output results
    if [ $updated_count -gt 0 ] || [ $installed_count -gt 0 ]; then
        echo "Files updated: $updated_count"
        echo "Files installed: $installed_count"
    fi
}

# Function to handle script options
handle_options() {
    local OPTIND opt
    while getopts ":b:v:h" opt; do
        case ${opt} in
            b )
                BACKUP=true
                ;;
            v )
                VERBOSE=true
                ;;
            h )
                echo "Usage: $0 [-b] [-v] [-h]"
                echo "  -b, --backup    Create a backup of existing configuration files before updating."
                echo "  -v, --verbose   Enable verbose output."
                echo "  -h, --help      Display this help message."
                exit 0
                ;;
            \? )
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
            : )
                echo "Invalid option: -$OPTARG requires an argument" >&2
                exit 1
                ;;
        esac
    done
    shift $((OPTIND -1))
}

# Handle options
handle_options "$@"

# Step 1: Clone or Pull Repository
echo "Fetching Anet_ET4 repository..."
if [ ! -d "$LOCAL_REPO_FOLDER" ]; then
    git clone -b $REPO_BRANCH $REPO_URL $LOCAL_REPO_FOLDER & spinner
else
    cd $LOCAL_REPO_FOLDER
    git config pull.ff only   # Set fast-forward only strategy
    git pull origin $REPO_BRANCH & spinner
fi

echo "Fetching klipper-macros repository..."
if [ ! -d "$LOCAL_REPO_FOLDER/klipper-macros" ]; then
    git clone -b $KLIPPER_MACROS_REPO_BRANCH $KLIPPER_MACROS_REPO_URL "$LOCAL_REPO_CONFIG_FOLDER/klipper-macros" & spinner
else
    cd "$LOCAL_REPO_CONFIG_FOLDER/klipper-macros"
    git config pull.ff only   # Set fast-forward only strategy
    git pull origin $KLIPPER_MACROS_REPO_BRANCH & spinner
fi

echo "Working..."

# Step 2: Check and Create necessary directories if not exist
mkdir -p "$DESTINATION_FOLDER"
mkdir -p "$KLIPPER_CONFIGS_FOLDER"
mkdir -p "$KLIPPER_MACROS_FOLDER"
mkdir -p "$OPTIONAL_MACROS_FOLDER"

# Step 3: Copy Updated Files
echo "Copying files..."
copy_updated_files "$LOCAL_REPO_CONFIG_FOLDER" "$DESTINATION_FOLDER"
copy_updated_files "$LOCAL_REPO_FOLDER/klipper-configs" "$KLIPPER_CONFIGS_FOLDER"
copy_updated_files "$LOCAL_REPO_FOLDER/klipper-macros" "$KLIPPER_MACROS_FOLDER"

# Specific handling for printer.cfg
echo "Copying printer.cfg..."
if [ -f "$LOCAL_REPO_CONFIG_FOLDER/printer.cfg" ]; then
    cp -f "$LOCAL_REPO_CONFIG_FOLDER/printer.cfg" "$DESTINATION_FOLDER/"
    echo "printer.cfg has been copied to $DESTINATION_FOLDER/"
fi

# Summary
echo "Files copied to destination folders."
