#!/bin/bash

# colors
declare -A COLORS=(
    ["red"]="\e[31m"
    ["green"]="\e[32m"
    ["yellow"]="\e[33m"
    ["blue"]="\e[34m"
    ["magenta"]="\e[35m"
    ["cyan"]="\e[36m"
    ["white"]="\e[37m"
    ["reset"]="\e[0m"
)

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_JSON_FILE=$ROOT_DIR/packages.json
HOME_PKG_JSON_FILE="${XDG_DATA_HOME:-$HOME}/base/packages.json"
POXI="pacman"
BACKGROUND=false
ACCEPT_ALL=false

check_json_file(){
    data='
    {
        "required": {
            "editor": ["neovim", "helix", "micro"],
            "terminal": ["alacritty", "kitty"],
            "utilites": ["moreutils", "fzf", "eza", "zoxide", "zsh"]
        },
        "installed": [
            "bat"
        ]
    }
    '
    if [[ -f "$PKG_JSON_FILE" ]]; then
        return
    else
        echo "Creating $(basename $PKG_JSON_FILE) file."
        echo $PKG_JSON_FILE
        result=$(echo "$data" | jq '.' > $PKG_JSON_FILE) && echo 0 || echo 1
        echo $result
    fi
}

# installation simmulation
function simmulate_install {
    for pkg in $@; do
        printf "󰦗 installing $pkg...\n"
        POXI=$(printf "pacman -S --needed %s %s" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg")
        echo $POXI
        sleep 2&
    done
    wait
    echo " installation done"
}

# remove simmulation
function simmulate_remove {
    for pkg in $@; do
        printf "󰦗 Removing $pkg...\n"
        sleep 2&
    done
    wait
    echo " Removal done"
}

## get package information
get_package_detail() {
    local PKG=$1
    local Preview="$($POXI --color=always -Si $PKG)"
    echo "$Preview"
}

## get all packages name and return selected pkgs in one string
get_all_packages(){
    local PKGS="$($POXI --color=always -Sl \
    | head -n 5 \
    | fzf --ansi --multi --sync \
    | awk '{s = s $1 "/" $2 " "} END {print s}')"
    echo $PKGS
}

## get all installed packages name and return selected pkgs in one string
get_installed_packages() {
    local PKGS="$($POXI --color=always -Qe \
    | head -n 5 \
    | fzf --ansi --multi --sync \
    | awk '{s=s $1 " "} END{print s}')"
    echo $PKGS  
}

