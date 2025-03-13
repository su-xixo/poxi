#!/bin/bash

# Define variables
# colors
bold="\e[1m"
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
magenta="\e[35m"
cyan="\e[36m"
white="\e[37m"
reset="\e[0m"

URL="https://example.com/path/to/your_script.sh"
INSTALL_DIR="/usr/local/bin"
TEMP_DIR=$(mktemp -d)
USER=$(whoami)
declare -A DEPENDENCIES=(
    ['base']='curl jq sponge fzf'
    ['aur']='yay paru'
)

function check_depds {
    echo -e "${yellow} Checking base dependencies${reset}"
    for pkg in ${DEPENDENCIES['base']}; do
        if command -v "$pkg" >/dev/null 2>&1;then
            echo -n "    ";echo -e "${bold}${green}${reset} $pkg found" && sleep 0.5
        else
            echo -n "    ";echo -e "${bold}${red}${reset} $pkg found" && sleep 0.5
        fi
    done
    echo -e "${yellow} Checking aur dependencies${reset}"
    for pkg in ${DEPENDENCIES['aur']}; do
        if command -v "$pkg" >/dev/null 2>&1; then
            echo -n "    ";echo -e "${bold}${green}${reset} $pkg found" && sleep 0.5
            break
        fi
    done
}
check_depds