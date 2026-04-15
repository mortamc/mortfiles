#!/bin/bash

echo "🚀 Starting mortfiles installation..."

# Create the .config folder if it doesn't exist
mkdir -p ~/.config

# 1. Copy program configurations to the system
cp -r .config/* ~/.config/

# 2. Copy the assets (Wallpapers, Logos) to their new home
# IMPORTANT: Your configs must point to ~/.config/assets/
cp -r assets ~/.config/

echo "✅ Installation completed successfully!"
echo "Remember to restart Hyprland (Super + M) to see the changes."
