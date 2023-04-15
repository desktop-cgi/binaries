#!/bin/bash

# determine machine architecture
arch=$(uname -m)
case $arch in
    x86_64) url="https://www.7-zip.org/a/7z2107-mac.tar.xz" ;;
    arm64)  url="https://www.7-zip.org/a/7z2107-mac.tar.xz" ;;
    *)      echo "Unsupported architecture: $arch" && exit 1 ;;
esac

# download 7-Zip
curl -OL $url

# extract archive
tar xf 7z*.tar.xz

# add 7z executable to PATH
export PATH="$PWD:$PATH"

# test installation
7z --help

echo "7-Zip installation complete."
