#!/bin/zsh

# This script is used to backup my Zettlr notes.
# TODO: This could all be done with some sort of library instead, it would be neater and easier to maintain.

# Color setup
autoload -U colors
colors

# Recordkeeping
local time=$(date)
local current_user=$(id -un)
echo "\n\nThis script was run at ${bold_color}${time}${reset_color}, by the user ${bold_color}${current_user}${reset_color}."

# Desired user directory (argument 1)
local desiredUser=$1

# Directory existence checks
if test -d /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/ZettlrBackup; then
    echo "ZettlrBackup directory exists in iCloud Drive."
else
    echo "ZettlrBackup directory does not exist in iCloud Drive. Creating directory."
    mkdir /Users/${desiredUser}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/ZettlrBackup
fi

# The following files are the files recommended by the doc page at:
# https://docs.zettlr.com/en/getting-started/migrating/
# TODO: turn this into a for loop

echo "Starting backup with rsync."

echo "${bold_color}\nstats.json${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/stats.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\nconfig.json${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/config.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\ncustom.json${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/custom.css /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\ntags.json${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/tags.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\ntargets.json${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/targets.json /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\nuser.dic${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/user.dic /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\ndefaults${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/defaults /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup
echo "${bold_color}\nsnippets${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Library/Application\ Support/Zettlr/snippets /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup

echo "${bold_color}\nNotes${reset_color}"
rsync -av --exclude=".DS_Store" --exclude=".Trash/" /Users/${desiredUser}/Notes /Users/${desiredUser}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/ZettlrBackup

echo "Backup successful."
exit 0
