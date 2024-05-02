#!/bin/zsh

# This script backs up all (disclaimer: not yet) of my important files. This is designed specifically for my
# MacOS system, and is not applicable anywhere else without adaptation.

# The crontab is:
# 0 19 * * * /usr/bin/sudo /Users/${desired_user}/Coding/scripts/BackupScripts/Backup.zsh >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/Backup.log

local time=$(date)
echo "\nThis script was run at $time."
filename_safe_time=$(date +"%Y-%m-%d_%H-%M-%S")

# Setup colors properly using zsh.sourceforge.io/Doc/Release/User-Contributions.html#index-colors
# Reference: echo $bold_color$fg[red]bold red ${reset_color}plain$'\e['$color[underline]m underlined
# Total set is: black, red, green, yellow, blue, magenta, cyan, and white for colors,
# bold, faint, standout, underline, blink, reverse, and conceal for intensity,
# and none (reset all attributes to the defaults), normal (neither bold nor faint), no-standout, 
# no-underline, no-blink, no-reverse, and no-conceal

autoload -U colors
colors

# Checks to see which user should be backed up. If there is only one user, that user is backed up.
# Bases this on whether or not the user has a Notes directory in their home directory.
# This is to stop this breaking if I ever have to use this on a system with multiple users or rename my user.
local userList=($(dscl . -list /Users | grep -vE '^_|daemon|nobody|root'))
local user_count=${#userList[@]} # Get the number of users
local desired_user=""

if [ $user_count -gt 1 ]; then
    echo "There are multiple users on this system. Finding the correct user by searching for a \"Notes\" directory in their home directory."
    local possible_users=()
    for user in "${userList[@]}"; do
        if [ -d /Users/${user}/Notes ]; then
            possible_users+=("$user")
            echo "User found: $user"
        fi
    done
    if [ ${#possible_users[@]} -gt 1 ]; then
        echo "There are multiple users with a Notes directory." 
        echo "$fg[red] You gotta code this part. Note that you also need to do that for the other script if you do this one. ${reset_color}" # TODO
        echo "The users with a Notes directory are: ${possible_users[@]}"
        exit 1
    else
        desired_user=${possible_users[0]}
        echo "The user with a Notes directory is $desired_user. Using that user."
    fi
else
    desired_user=$userList
    echo "There is only one user on this system. The user is $desired_user."
fi

# iCloud Drive check.
if test -d /Users/${desired_user}/Library/Mobile\ Documents/com~apple~CloudDocs; then
    echo "iCloud Drive exists."
else
    echo "iCloud Drive does not exist at expected path. Please recheck your user name and path."
    exit 1
fi

# iCloud Drive backup folder check.
if test -d /Users/${desired_user}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups; then
    echo "ScriptedBackups folder exists."
else
    echo "ScriptedBackups folder does not exist at expected path. Please create the folder. This is not created automatically in case it causes problems."
    exit 1
fi

# Running backup scripts. 
# TODO: turn this into a for loop

## Zettlr Backup
echo "$bold_color Starting backup of Zettlr notes and configuration data. $reset_color"

# Capture both stdout and stderr and pass them into log files. Also gets the exit code and prints whether the code ran successfully or not.
tmp_stderr=$(mktemp)
{ stdout=$(/Users/${desired_user}/Coding/scripts/BackupScripts/BackupZettlr.zsh $desired_user); } 2> "$tmp_stderr"
local Zettlr_exit_code=$?
stderr=$(<"$tmp_stderr")
rm "$tmp_stderr"

# Save the outputs to their log files
echo -e "$date$stdout" >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/BackupZettlr_stdout.log
echo -e "$date$stderr" >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/BackupZettlr_stderr.log

if [ $Zettlr_exit_code -eq 0 ]; then
    echo "$bold_color Zettlr backup completed successfully. $reset_color"
else
    echo "$bold_color Zettlr backup failed. $reset_color"
    echo "$stderr"
fi

## Thunderbird Backup
echo "$bold_color Starting backup of Thunderbird profiles. $reset_color"

# Capture both stdout and stderr and pass them into log files. Also gets the exit code and prints whether the code ran successfully or not.
tmp_stderr=$(mktemp)
{ stdout=$(/Users/${desired_user}/Coding/scripts/BackupScripts/BackupThunderbird.zsh $desired_user); } 2> "$tmp_stderr"
local Thunderbird_exit_code=$?
stderr=$(<"$tmp_stderr")
rm "$tmp_stderr"

# Save the outputs to their log files
echo -e "$date$stdout" >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/BackupThunderbird_stdout.log
echo -e "$date$stderr" >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/BackupThunderbird_stderr.log

if [ $Thunderbird_exit_code -eq 0 ]; then
    echo "$bold_color Thunderbird backup completed successfully. $reset_color"
else
    echo "$bold_color Thunderbird backup failed. $reset_color"
    echo "$stderr"
fi

## Stardew Valley Backup
echo "$bold_color Starting backup of Stardew Valley saves and mods. $reset_color"

# Capture both stdout and stderr and pass them into log files. Also gets the exit code and prints whether the code ran successfully or not.
tmp_stderr=$(mktemp)
{ stdout=$(/Users/${desired_user}/Coding/scripts/BackupScripts/BackupStardew.zsh $desired_user); } 2> "$tmp_stderr"
local Stardew_exit_code=$?
stderr=$(<"$tmp_stderr")
rm "$tmp_stderr"

# Save the outputs to their log files
echo -e "$date$stdout" >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/BackupStardew_stdout.log
echo -e "$date$stderr" >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/BackupStardew_stderr.log

if [ $Stardew_exit_code -eq 0 ]; then
    echo "$bold_color Stardew backup completed successfully. $reset_color"
else
    echo "$bold_color Stardew backup failed. $reset_color"
    echo "$stderr"
fi