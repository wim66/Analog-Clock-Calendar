#!/bin/bash
cd "$(dirname "$0")"

# Check if zenity is installed
if ! command -v zenity &> /dev/null; then
    echo "Zenity is not installed. Install it with: sudo pacman -S zenity"
    notify-send "Zenity missing" "Please install Zenity via your package manager."
    exit 1
fi

# Available colors
COLORS=("gray" "blue" "red" "orange" "green" "purple" "slot")
FILE="layout.lua"

# Show selection window with Zenity
CHOICE=$(zenity --list \
    --title="Choose a color" \
    --column="Color" \
    "${COLORS[@]}")

# Check if a choice was made
if [[ -z "$CHOICE" ]]; then
    echo "No choice made."
    exit 1
fi

NEW_COLOR="$CHOICE"

# Replace color values in the file
sed -i -E "s/(local my_box_colour\s*=\s*colours\.box_)[a-zA-Z_]+/\1$NEW_COLOR/" "$FILE"
sed -i -E "s/(local my_border_colour\s*=\s*colours\.border_)[a-zA-Z_]+/\1$NEW_COLOR/" "$FILE"

# Confirmation with Zenity
zenity --info --title="Color Set" --text="Color set to '$NEW_COLOR' in $FILE"

# Ask user if they want to start Conky now
if zenity --question --title="Start Conky?" --text="Do you want to start Conky now?"; then
    cd .. && sh start.sh
fi

exit 0
