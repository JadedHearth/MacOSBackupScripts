#!/bin/zsh

# This script ensures that the backups are downloaded before the main backup scripts run.

# Note that the crontab is:
# 50 18 * * * /Users/${desired_user}/Coding/scripts/BackupScripts/BackupEnsureDownloaded.zsh >> /Users/${desired_user}/Coding/scripts/BackupScripts/BackupEnsureDownloaded.log

# Setup colors properly using zsh.sourceforge.io/Doc/Release/User-Contributions.html#index-colors
autoload -U colors
colors

# Recordkeeping
local time=$(date)
echo "This script was run at $bold_color$time$reset_color. \n"

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

# Determine disk space
local remaining_disk_space_GB=$(df / | sed '1d' |
    awk '
        /^\/dev\/disk1s1s1/ {
            avail_byte = $4 * 512
            total_avail_gb = avail_byte / 1000000000

            printf total_avail_gb }
    '
)

local total_size_gb=$(df / | sed '1d' |
    awk '/^\/dev\/disk1s1s1/ {
            size_byte = $2 * 512     # df uses 512 byte blocks
            total_size_gb = size_byte / 1000000000

            printf total_size_gb }
    '
)

if [ $((remaining_disk_space_GB/total_size_gb < 0.04)) ]; then
    echo "Too little disk space left, reason: free space percentage less than 4%."
    exit 1
fi

if [ $((remaining_disk_space_GB < 10.00)) ]; then
    echo "Too little disk space left, reason: free space percentage less than 10GB."
    exit 1
fi

# Running backup scripts.

## Log Download
find /Users/${desired_user}/Library/Mobile\ Documents/com~apple~CloudDocs/ScriptedBackups/Logs -type f -exec brctl download {} \;
