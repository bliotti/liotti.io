#!/bin/bash

# Check for root/sudo permissions
if [ "$EUID" -ne 0 ]
  then echo "Please run as root or use sudo"
  exit
fi

# Download the idk script and install it
curl -fsSL https://coinguy.io/idk -o /usr/local/bin/idk

# Make the script executable
chmod +x /usr/local/bin/idk

echo "idk command installed successfully!"
