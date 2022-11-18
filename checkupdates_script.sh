#!/bin/bash

runningPath=/tmp/updator_running.tmp
updateRefusedPath=/tmp/updator_updateRefused.tmp


if [ -f $runningPath ] || [ -f $updateRefusedPath ]; then
    exit 0
fi

touch $runningPath

checkupdates 2>&1 > /dev/null

if [ $? -eq 0 ]; then
    response=`notify-send -u critical -i dialog-question "You have updates available" "Do you want to apply the updates ?" -A "Yes" -A "No"`
    if [ "$response" == "0" ]; then
        notify-send -i dialog-question "Applying available updates"
        $HOME/.local/etc/./update_script.sh
    else
        touch $updateRefusedPath
    fi
fi

rm -f $runningPath
