#!/bin/bash

# --- Configuration & Safety ---
set -e # Exit on error
set -u # Exit on unset variables

# Ensure script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "Error: This script must be run as root."
   exit 1
fi

# --- Functions ---
update_system() {
    echo "Updating and upgrading system packages..."
    apt update && apt upgrade -y
    apt install unzip
}

install_php_env() {    echo "Fetching and executing PHP setup script..."
    local script_url="https://raw.githubusercontent.com/onixsat/fox/refs/heads/main/php.sh"
    local temp_script="/tmp/php_setup.sh"
    
    wget -q "$script_url" -O "$temp_script"
    bash "$temp_script"
    rm -f "$temp_script"
}

setup_web_root() {
    local target_dir="/var/www/html"
    echo "Configuring web root at $target_dir..."
    
    mkdir -p "$target_dir"
    cd "$target_dir"
    
    # Create index.php with content
    echo "var/www/html/index.php" > index.php
    
    # Set appropriate permissions (Best Practice)
    chown -R www-data:www-data "$target_dir"
    chmod -R 777 "$target_dir"
}

# --- Execution ---
update_system
install_php_env
setup_web_root

echo "Automation completed successfully."

# --- Cron Job Option ---
# To schedule this script to run weekly (e.g., every Sunday at midnight):
# (crontab -l 2>/dev/null; echo "0 0 * * 0 /path/to/this_script.sh") | crontab -
