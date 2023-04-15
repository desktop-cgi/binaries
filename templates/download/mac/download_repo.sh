#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <config_file> <download_key> [<download_key>...]"
    exit 1
fi

# If neither curl nor wget is installed, install curl and download the file using curl
if command -v apt-get >/dev/null 2>&1; then
    # If apt-get is available, install curl using apt-get
    sudo apt-get update && sudo apt-get install -y curl
elif command -v yum >/dev/null 2>&1; then
    # If yum is available, install curl using yum
    sudo yum update && sudo yum install -y curl
elif command -v pacman > /dev/null; then
    # If pacman is available, install curl using pacman
    sudo pacman -S --noconfirm curl
elif command -v brew > /dev/null; then
    # If brew is available, install curl using brew
    brew install curl
else
    # If neither apt-get nor yum is available, print an error message and exit with status 1
    echo "Error: cannot install curl (neither apt-get nor yum is available)"
    exit 1
fi

# Check if jq is installed, and if not, try to install it
if ! command -v jq > /dev/null; then
    if command -v apt-get > /dev/null; then
        sudo apt-get install -y jq
    elif command -v yum > /dev/null; then
        sudo yum install -y jq
    elif command -v pacman > /dev/null; then
        sudo pacman -S --noconfirm jq
    elif command -v brew > /dev/null; then
        brew install jq
    else
        echo "jq not found and no package manager available to install it"
        exit 1
    fi
fi

config_file=$1

if [ ! -f "$config_file" ]; then
    echo "Config file not found: $config_file"
    exit 1
fi

shift

download_keys=("$@")

json=$(cat "$config_file" | jq -c '.')

if [ -z "$json" ]; then
    echo "Invalid config file: at least one download key must be provided."
    exit 1
fi

for key in "${download_keys[@]}"; do
    if [ ! "$(echo "$json" | jq -r ".\"$key\"")" ]; then
        echo "Download key not found in config file: $key"
        exit 1
    fi

    url=$(echo "$json" | jq -r ".\"$key\".url")
    tmp=$(echo "$json" | jq -r ".\"$key\".tmp")
    dest=$(echo "$json" | jq -r ".\"$key\".dest")
    compresstype=$(echo "$json" | jq -r ".\"$key\".compresstype")

    temp_folder="$tmp/$key"
    temp_file="$temp_folder/$key.$compresstype"

    mkdir -p "$temp_folder"

    echo "Downloading $url to $temp_file..."

    ./download_extract.sh "$compresstype" "$url" "$temp_folder" "$dest"

    if [ ! -f "$temp_file" ]; then
        echo "Download failed: $temp_file not found."
        exit 1
    fi

    echo "Done downloading $key."
done

echo "All downloads complete."
