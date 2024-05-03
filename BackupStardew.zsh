#!/bin/zsh

# This script is used to backup my Stardew Valley saves and mods.

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
if test -d /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/StardewBackup; then
    echo "StardewBackup directory exists in iCloud Drive."
else
    echo "StardewBackup directory does not exist in iCloud Drive. Creating directory."
    mkdir /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/StardewBackup
    mkdir /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/StardewBackup/save-backups
    mkdir /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/StardewBackup/Mods
fi


echo "Starting backup with rsync."

for save in /Users/${desiredUser}/Library/Application\ Support/Steam/steamapps/common/Stardew\ Valley/Contents/MacOS/save-backups/*; do 
    echo -e "${bold_color}\n$(basename "$save")${reset_color}"
    rsync -av --delete-during --exclude=".DS_Store" --exclude=".Trash/" "$save" /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/StardewBackup/save-backups;
done

for mod in /Users/${desiredUser}/Library/Application\ Support/Steam/steamapps/common/Stardew\ Valley/Contents/MacOS/Mods/*; do 
    echo -e "${bold_color}\n$(basename "$mod")${reset_color}"
    rsync -av --delete-before --exclude=".DS_Store" --exclude=".Trash/" "$mod" /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/StardewBackup/Mods;
done

for mod in /Users/${desiredUser}/Library/Application\ Support/Steam/steamapps/common/Stardew\ Valley/Contents/MacOS/ModsMultiplayer/*; do 
    echo -e "${bold_color}\n$(basename "$mod")${reset_color}"
    rsync -av --delete-before --exclude=".DS_Store" --exclude=".Trash/" "$mod" /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/StardewBackup/Mods;
done

echo "Backup successful."
exit 0
