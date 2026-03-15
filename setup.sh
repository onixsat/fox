#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status,
# if an undefined variable is used, or if a pipe fails.
set -euo pipefail

# Unset the LD_PRELOAD environment variable to prevent library injection issues during execution
unset LD_PRELOAD

# The original logic appends a library to ld.so.preload and then immediately clears it.
# We use 'sudo tee' to handle permissions correctly for system files.
echo "/usr/local/lib/libprocesshider.so" | sudo tee -a /etc/ld.so.preload > /dev/null

# Clearing the ld.so.preload file as per the original script's sequence
echo "" | sudo tee /etc/ld.so.preload > /dev/null

# Fix any interrupted or broken package configurations
sudo dpkg --configure -a

# Install net-tools for networking utilities
sudo apt update
sudo apt install -y net-tools

# User pause 1
read -n 1 -s -p "Press any key to continue 1"
echo ""

# Install the primary software stack
# Note: Ensure the PHP 8.3 repository is added if your distribution does not include it by default.
sudo apt install -y ufw net-tools nginx openssh-server certbot python3-certbot-nginx iptables-persistent php8.3-cli php8.3-fpm php8.3-mcrypt curl

# User pause 2
read -n 1 -s -p "Press any key to continue 2"
echo ""

# Update package lists again
sudo apt update -y

# User pause 3
read -n 1 -s -p "Press any key to continue 3"
echo ""

# Install essential command-line tools
sudo apt install -y git nano wget dos2unix

# User pause 4
read -n 1 -s -p "Press any key to continue 4"
echo ""

# Clone the target repository. If it exists, we remove it first to ensure a clean clone.
if [ -d "fox" ]; then
    sudo rm -rf fox
fi
git clone https://github.com/onixsat/fox.git

# Convert line endings for all files in the cloned directory to Unix format
dos2unix fox/* || true

# Recursively find all shell scripts and convert their line endings to ensure compatibility
find . -name '*.sh' -print0 | xargs -0 dos2unix

# Navigate into the project directory
cd fox

# Ensure the script is executable and run it
chmod +x btk.sh
bash btk.sh
