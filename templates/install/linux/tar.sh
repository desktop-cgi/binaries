#!/bin/bash

# Determine package manager
if [ -x "$(command -v apt-get)" ]; then
  # Debian-based system
  sudo apt-get update
  sudo apt-get install -y tar
elif [ -x "$(command -v yum)" ]; then
  # RPM-based system
  sudo yum install -y tar
elif [ -x "$(command -v dnf)" ]; then
  # RPM-based system with dnf
  sudo dnf install -y tar
elif [ -x "$(command -v brew)" ]; then
  # Homebrew package manager
  brew update
  brew install tar
elif [ -x "$(command -v port)" ]; then
  # MacPorts package manager
  sudo port selfupdate
  sudo port install tar
else
  echo "Unsupported package manager. Please install tar manually."
  exit 1
fi

echo "Tar installed successfully."
