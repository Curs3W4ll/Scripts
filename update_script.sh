#!/bin/bash

logsPath=/tmp/updatelogs.txt

sudo -A pacman -Syu --noconfirm 2>&1 > $logsPath

if [ $? -ne 0 ]; then
    response=`notify-send -u critical -i face-sad "Update failed" "$(cat $logsPath)" -A "View logs"`
    if [ "$response" == "0" ]; then
        terminator -e "nvim $logsPath"
    fi
else
    notify-send -u critical -i face-cool "Update finished successfully"
fi
