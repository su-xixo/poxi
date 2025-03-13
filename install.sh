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

PKGNAME="poxi"
URL="https://github.com/su-xixo/poxi.git"
SOURCE_DIR="/usr/local/share/$PKGNAME"
SOURCE_DIR="$HOME/.local/share/$PKGNAME"

INSTALL_DIR="/usr/local/bin"
INSTALL_DIR="$HOME/.local/bin"
TEMP_DIR=$(mktemp -d)
USER=$(whoami)
declare -A DEPENDENCIES=(
    ['base']='git curl jq moreutils fzf'
    ['aur']='yay paru'
)

# # check for root user
# if [[ ! "$USER" == 'root' || ! $EUID -eq 0 ]]; then
#     echo -e "${red} WARNING:${reset} sudo privileges is required to run the script" 
#     exit 1
# fi

function usage {
  echo "Usage: $(basename $0) {install|remove|update}"
  exit 1
}

function cleanup {
    local remove_source="$SOURCE_DIR"
    local remove_install="$INSTALL_DIR/$PKGNAME"
    if [[ -d $remove_source ]]; then
        echo -e "${red}${reset} Removing share/poxi folder from ${bold}$remove_source${reset}"
        rm -rf "$remove_source"
    fi

    if [[ -L $remove_install ]]; then
        echo -e "${red}${reset} Removing poxi symlink file from ${bold}$remove_install${reset}"
        rm -rf "$remove_install"
    fi
}

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

# check_depds
function install {
    check_depds
    # 1. check if already installed
    if command -v "$PKGNAME" >/dev/null 2>&1; then
        echo -e "${cyan} package already present${reset}"
        return
    fi

    # 2. download package
    echo -e "${yellow} Downloading package...${reset}"
    git clone --branch "$(git ls-remote --tags --sort="v:refname" $URL | tail -n1 | sed 's/.*\///; s/\^{}//')" --single-branch $URL $TEMP_DIR
    
    if [[ $? -ne 0 ]]; then
        echo -e "${red} Failed to download script${reset}"
        return
    fi

    # 3. install package
    echo -e "${yellow} Installing script...${reset}"
    if [ ! -d "$SOURCE_DIR" ]; then
        mkdir -p "$SOURCE_DIR"
    fi
    cp -r "$TEMP_DIR"/* "$SOURCE_DIR"
    ln -sf $SOURCE_DIR/$PKGNAME $INSTALL_DIR/$PKGNAME
    if [ $? -ne 0 ]; then
        echo -e "${red}Warning:${reset} Failed to create symlink."
        cleanup
        return
    fi
    echo -e "${green} Script installed successfully to $INSTALL_DIR/$PKGNAME${reset}"
}
function remove {
    cleanup
}


{
    if [ $# -ne 1 ]; then
        usage
    fi

    case "$1" in
    install)
        install
        ;;
    remove)
        remove
        ;;
    *)
        usage
        ;;
    esac
    rm -rf "$TEMP_DIR"
}