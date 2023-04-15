#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Usage: $0 <config_file> <download_key> [<download_key>...]"
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

    # ./download_extract.sh "$compresstype" "$url" "$temp_folder" "$dest"

    # check if compression type, URL, tmp folder, and destination folder are provided in command line argument
    if [ -z "$compresstype" ] || [ -z "$url" ] || [ -z "$tmp" ] || [ -z "$dest" ]; then
        echo "Usage: download_extract.sh <compressiontype> <url> <tmp> <destination>"
        exit 1
    fi

    # assign command line arguments to variables
    COMPRESSION_TYPE="$compresstype"
    URL="$url"
    TEMP_FOLDER="$tmp"
    TARGET_FOLDER="$dest"
    EXEC_PATH="$source_path/$exec_name"

    # check if destination and target folders exist, create them if not
    mkdir -p "$TEMP_FOLDER" "$TARGET_FOLDER"

    # determine file extension
    FILE_EXT=${URL##*.}

    # download file and save to destination folder
    if type "curl" >/dev/null 2>&1; then
        curl -fsSL "$URL" -o "$TEMP_FOLDER/file%s"
    elif type "wget" >/dev/null 2>&1; then
        wget -q "$URL" -P "$TEMP_FOLDER" -O "$TEMP_FOLDER/file%s"
    else
        echo "Error: neither curl nor wget is installed"
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "Error: Download failed"
        rm -f "$TEMP_FOLDER/file%s"
        exit 1
    fi

    # extract file if it is an archive
    cd "$TEMP_FOLDER"
    if [ "$COMPRESSION_TYPE" == "zip" ] && [ "$FILE_EXT" == "zip" ]; then
        unzip -qq "file%s" -d "$TARGET_FOLDER"
        rm -f "file%s"
    elif [ "$COMPRESSION_TYPE" == "tar" ] && [ "$FILE_EXT" == "tar" ]; then
        tar -xf "file%s" -C "$TARGET_FOLDER"
        rm -f "file%s"
    elif [ "$COMPRESSION_TYPE" == "tar.xz" ] && [ "$FILE_EXT" == "tar.xz" ]; then
        tar -xJf "file%s" -C "$TARGET_FOLDER"
        rm -f "file%s"
    elif [ "$COMPRESSION_TYPE" == "tar.gz" ] && [ "$FILE_EXT" == "tar.gz" ]; then
        tar -xzf "file%s" -C "$TARGET_FOLDER"
        rm -f "file%s"
    elif [ "$COMPRESSION_TYPE" == "rar" ] && [ "$FILE_EXT" == "rar" ]; then
        unrar x -o+ "file%s" "$TARGET_FOLDER"
        rm -f "file%s"
    else
        echo "Error: Compression type does not match file extension."
        rm -f "file%s"
        exit 1
    fi

    if [ $? -ne 0 ]; then
        echo "Error: Extraction failed"
        exit 1
    fi

    echo "Download complete."

    if [ ! -f "$temp_file" ]; then
        echo "Temporary File Deleted: $temp_file not found."
        exit 1
    fi

    echo "Done downloading $key."
    
done

echo "All downloads complete."
