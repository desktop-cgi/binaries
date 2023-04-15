#!/bin/bash

# 
# Usage: download_extract.sh <compressiontype> <url> <destination> <target>
# Arguments:
# - <compressiontype>: The compression type of the downloaded file, e.g. zip, tar, tar.xz, tar.gz, rar.
# - <url>: The URL of the file to download.
# - <destination>: The destination folder to save the downloaded file.
# - <target>: The target folder to extract the downloaded file.
# Example: download_extract.sh tar.gz https://example.com/file.tar.gz /tmp /ExtractedFiles
# 

# set default URL, destination folder, and target folder here
DEFAULT_URL=https://example.com/file.zip
TEMP_FOLDER=/tmp
TARGET_FOLDER=/ExtractedFiles

# check if compression type, URL, tmp folder, and destination folder are provided in command line argument
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Usage: download_extract.sh <compressiontype> <url> <tmp> <destination>"
    exit 1
fi

# assign command line arguments to variables
COMPRESSION_TYPE="$1"
URL="$2"
TEMP_FOLDER="$3"
TARGET_FOLDER="$4"

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
