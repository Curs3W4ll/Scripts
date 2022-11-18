#!/bin/bash

logsPath=/tmp/updatelogs.txt


if [ -n "$1" ]; then
    visualBin=$1
else
    which nvim 2>&1 > /dev/null
    if [ $? -eq 0 ]; then
        vimBin=nvim
    else
        vimBin=vi
    fi
    visualBin=${VISUAL:-$vimBin}
fi

sudo -A pacman -Syu --noconfirm 2>&1 > $logsPath

if [ $? -ne 0 ]; then
    response=`notify-send -u critical -i face-sad "Update failed" "$(cat $logsPath)" -A "View logs"`
    if [ "$response" == "0" ]; then
        ${TERMINAL:-terminator} -e "nvim $logsPath"
    fi
else
    notify-send -u critical -i face-cool "Update finished successfully"
fi
