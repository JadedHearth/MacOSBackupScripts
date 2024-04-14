#!/bin/zsh

# This script backs up all of my important files. This is designed specifically for my
# MacOS system, and is not applicable anywhere else without adaptation.

# Note that the sudoers files was edited (sudo visudo) for this with this line:
# ${desired_user} ALL = (root) NOPASSWD: /Users/${desired_user}/Coding/scripts/BackupScripts/Backup.zsh
# Additionally, the editing of this file was restricted to root, by changing the ownership and write permissions:
# sudo chown root /Users/${desired_user}/Coding/scripts/BackupScripts/Backup.zsh
# sudo chmod 744 /Users/${desired_user}/Coding/scripts/BackupScripts/Backup.zsh 
# The crontab is:
# 0 12 * * * /usr/bin/sudo /Users/${desired_user}/Coding/scripts/BackupScripts/Backup.zsh >> /Users/${desired_user}/Library/Mobile\ Documents/com\~apple\~CloudDocs/ScriptedBackups/Logs/Backup.log

local time=$(date)
echo "This script was run at $time. \n"
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
        echo "There are multiple users with a Notes directory.$fg[red] You gotta code this part.${reset_color}"
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

# Permissions check. This script must be run with sudo, as otherwise it cannot edit the iCloud Drive
# folder. There's probably a more secure way of doing this, as this way leaves the possibility of a
# vulnerability in one of the used commands running arbitrary code as _root_! Investigate launchctl
# and iCloud development tools please.

current_user=$(id -un)

if [ -n "$SUDO_USER" ]; then
    echo "Current user is $current_user, so the script is running as root."
else
    echo "Current user is $current_user, so the script is not running as root. Exiting."
    exit 126
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
