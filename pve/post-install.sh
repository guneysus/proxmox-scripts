#!/bin/bash

# Define the packages to install
PACKAGES="vim git htop nala"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Starting Proxmox post-installation utility script..."

# --- Update package list ---
echo "Updating package list..."
apt update -y

# --- Install nala (and fallback if needed) ---
if ! command -v nala &> /dev/null
then
    echo "nala not found. Attempting to install nala..."
    if apt install nala -y; then
        echo "nala installed successfully."
        PKG_CMD="nala"
    else
        echo "Failed to install nala. Falling back to apt for package installation."
        PKG_CMD="apt"
    fi
else
    echo "nala is already installed."
    PKG_CMD="nala"
fi

# --- Install remaining packages using the preferred package manager ---
echo "Checking and installing required packages: $PACKAGES"

for PKG in $PACKAGES; do
    if ! dpkg -l | grep -qw "$PKG"; then
        echo "Installing $PKG..."
        $PKG_CMD install "$PKG" -y
        if [ $? -ne 0 ]; then
            echo "Warning: Installation of $PKG failed."
        else
            echo "$PKG installed."
        fi
    else
        echo "$PKG is already installed. Skipping."
    fi
done

echo "Proxmox post-installation script finished."