#!/bin/zsh

# This script is used to backup my Zettlr notes.

# Note that the editing of this file was restricted to root, by changing the ownership and write permissions, replacing ${desiredUser} with the desired user:
# sudo chown root /Users/${desiredUser}/Coding/scripts/BackupScripts/BackupZettlr.zsh
# sudo chmod 744 /Users/${desiredUser}/Coding/scripts/BackupScripts/BackupZettlr.zsh 
# This is to prevent unauthorized users from editing the script and running arbitrary code as root.

# Color setup
autoload -U colors
colors

# Desired user directory (argument 1)
local desiredUser=$1

# Current time
date

# Permissions check
local current_user=$(id -un)

if [ -n "$SUDO_USER" ]; then
    echo "Current user is $current_user, and the script is running with sudo permissions."
else
    echo "Current user is $current_user, and the script is not running with sudo permissions. Exiting."
    exit 126
fi

if test -d /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/ZettlrBackup; then
    echo "ZettlrBackup directory exists in iCloud Drive."
else
    echo "ZettlrBackup directory does not exist in iCloud Drive. Creating directory."
    mkdir /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/ZettlrBackup
fi

# The following files are the files recommended by the doc page at:
# https://docs.zettlr.com/en/getting-started/migrating/

echo "Starting backup with rsync."

echo "$bold_color\nstats.json$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/stats.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\nconfig.json$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/config.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\ncustom.json$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/custom.css /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\ntags.json$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/tags.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\ntargets.json$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/targets.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\nuser.dic$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/user.dic /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\ndefaults$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/defaults /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "$bold_color\nsnippets$reset_color"
rsync -av /Users/${desiredUser}/Library/Application\ Support/Zettlr/snippets /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup

echo "$bold_color\nNotes$reset_color"
rsync -av /Users/${desiredUser}/Notes /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup

echo "Backup successful."
exit 0
