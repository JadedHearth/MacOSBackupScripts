#!/bin/zsh

# This script is used to backup my Thunderbird profiles. (mainly a concern because I'm using a beta version)

# Color setup
autoload -U colors
colors

# Recordkeeping
local time=$(date)
local current_user=$(id -un)
echo "\n\nThis script was run at $bold_color$time$reset_color, by the user $bold_color$current_user$reset_color."

# Desired user directory (argument 1)
local desiredUser=$1

# Directory existence checks
if test -d /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/ThunderbirdBackup; then
    echo "ThunderbirdBackup directory exists in iCloud Drive."
else
    echo "ThunderbirdBackup directory does not exist in iCloud Drive. Creating directory."
    mkdir /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/ThunderbirdBackup
fi

# The backup of the profile is recommended at: 
# https://www.thunderbird.net/en-US/download/beta/
# Instructions at:
# https://support.mozilla.org/en-US/kb/profiles-where-thunderbird-stores-user-data#w_backing-up-a-profile

echo "Starting backup with rsync."

for profile in /Users/${desiredUser}/Library/Thunderbird/Profiles/*; do 
    echo -e "${bold_color}\n$(basename "$profile")${reset_color}"
    rsync -av --exclude=".DS_Store" --exclude=".Trash/" "$profile" /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ThunderbirdBackup;
done

echo "Backup successful."
exit 0
