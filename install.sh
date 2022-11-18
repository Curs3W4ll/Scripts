#!/bin/bash

NoColor="\033[0m"
CyanColor="\033[0;36m"
GreenColor="\033[0;32m"
RedColor="\033[0;91m"


scriptargs=" ${*:1} "
installslist=" ${*:2} "

installPath=""

input_asker_installed=false
updator_installed=false
update_detector_installed=false

function confirm {
    local _response
    while true; do
        if [ -n "$1" ]; then
            echo -n $1
        else
            echo -n "Are you sure"
        fi
        echo -n " [y/n] ? "
        read -r _response
        case "$_response" in
            [Yy][Ee][Ss]|[Yy]|"")
                return 0
            ;;
            [Nn][Oo]|[Nn])
                return 1
            ;;
            *)
                echo "Invalid input, Please response Yes or No"
            ;;
        esac
    done
}

function display_usage {
    echo -e "Usage: $0 installPath [specificInstalls...]\n"
    echo -e "  installPath   The path to install scripts in.\n"
    echo    "specificInstalls(optional):"
    echo    "  Giving no argument will install all the scripts."
    echo    "  input_asker      Install the graphic input asker script."
    echo    "  updator          Install the update with notifications script. This will install the input_asker."
    echo    "  update_detector  Install the updates detector script. This will install the updator."
}

function install_input_asker {
    if [ "$input_asker_installed" == true ]; then
        return
    fi

    if [ "$1" != "0" ]; then
        echo -e "${CyanColor}Installing input asker... $1${NoColor}"
    fi

    cp scripts/graphic_input_asker.sh $installPath/

    confirm "Do you want to use the graphic input asker as graphic prompt for sudo"
    if [ "$?" == "0" ]; then
        sudo echo "Path askpass $installPath/graphic_input_asker.sh" >> /etc/sudo.conf
    fi

    echo -e "${GreenColor}Input asker installed successfully${NoColor}"
    input_asker_installed=true
}

function install_updator {
    if [ "$updator_installed" == true ]; then
        return
    fi

    if [ "$1" != "0" ]; then
        echo -e "${CyanColor}Installing updator with notifications... $1${NoColor}"
    fi

    install_input_asker "(as a dependency of updator)"
    cp scripts/update_script.sh $installPath/

    echo -e "${GreenColor}Updator installed successfully${NoColor}"
    updator_installed=true
}

function install_update_detector {
    if [ "$update_detector_installed" == true ]; then
        return
    fi

    if [ "$1" != "0" ]; then
        echo -e "${CyanColor}Installing updates detector... $1${NoColor}"
    fi

    install_updator "(as a dependency of update detector)"
    cp scripts/checkupdates_script.sh $installPath/

    echo "Add the following lines to the top of your rc file to automatically start the script"
    echo "\`\`\`"
    echo "# Watch for system updates"
    echo "nohup $installPath/checkupdates_script.sh 2>/dev/null > /dev/null </dev/null &"
    echo "disown"
    echo "clear"
    echo "\`\`\`"

    echo -e "${GreenColor}Update detector installed successfully${NoColor}"
    update_detector_installed=true
}

function install_all {
    if [ "$1" != "0" ]; then
        echo -e "${CyanColor}Installing all the scripts... $1"
    fi
    install_input_asker
    install_updator
    install_update_detector
}

if [[ "$scriptargs" == *" -h "* ]] || [[ "$scriptargs" == *" --help "* ]] || [[ "$scriptargs" == *" help "* ]] || [[ "$scriptargs" == *" h "* ]]; then
    display_usage
    exit 0
fi

if [ -z "$1" ]; then
    echo -e "${RedColor}You should give the install path as first argument\n${NoColor}"
    display_usage
    exit 1
fi
installPath="$1"

mkdir -p $1 > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RedColor}As the directory you are trying to install in is protected, please start the script with root rights (with sudo)${NoColor}"
    exit 1
fi
touch $1/testfiletotestrights.tmp > /dev/null 2> /dev/null
if [ $? -ne 0 ]; then
    echo -e "${RedColor}As the directory you are trying to install in is protected, please start the script with root rights (with sudo)${NoColor}"
    exit 1
fi
rm -f $1/testfiletotestrights.tmp

if [ -z "$2" ]; then
    install_all
else
    if [[ "$scriptargs" == *" input_asker "* ]]; then
        install_input_asker
    fi
    if [[ "$scriptargs" == *" updator "* ]]; then
        install_updator
    fi
    if [[ "$scriptargs" == *" update_detector "* ]]; then
        install_update_detector
    fi
fi
