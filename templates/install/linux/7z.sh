#!/bin/bash

# Detect architecture of the system
if [ "$(uname -m)" = "x86_64" ]; then
  url="https://www.7-zip.org/a/7z2201-linux-x64.tar.xz"
elif [ "$(uname -m)" = "i686" ]; then
  url="https://www.7-zip.org/a/7z2201-linux-x86.tar.xz"
elif [ "$(uname -m)" = "aarch64" ]; then
  url="https://www.7-zip.org/a/7z2201-linux-arm64.tar.xz"
elif [ "$(uname -m)" = "armv7l" ]; then
  url="https://www.7-zip.org/a/7z2201-linux-arm.tar.xz"
else
  echo "Unsupported architecture"
  exit 1
fi

# Download and extract 7zip
wget "$url"
tar xf 7z*.tar.xz

# Add 7zip to the PATH
export PATH="$PATH:$(pwd)/7z*/bin"

# Test 7zip installation
7z --version

echo "7-Zip installation complete."
