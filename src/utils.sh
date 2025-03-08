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
# desktop name
DESKTOP=$DESKTOP_SESSION
# check if root
if [[ $EUID -eq 0 ]]; then
    POXI="pacman"
    is_root=true
else
    POXI="sudo pacman"
    is_root=false
fi
# set aur helper
for helper in paru yay; do
    if command -v $helper &>/dev/null; then
        AHELPER=$helper
        break
    fi
done

# printf "(pacman cmd: %s) and (aur helper cmd: %s)\n" "$POXI" "$AHELPER"

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
        POXI_install=$(printf "%s -S --needed %s %s" "$POXI" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg") # pacman -S --needed --noconfirm aur/pkg2

        if [[ $pkg =~ ^(aur\/) ]]; then
            POXI_install=$(printf "%s -S --needed %s %s" "$AHELPER" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg") # paru -S --needed --noconfirm aur/pkg2
        fi
        eval ${POXI_install}
        echo "$?"
    done
}

# remove simmulation
function simmulate_remove {
    for pkg in $@; do
        POXI_remove=$(printf "%s -Rns %s %s" "$POXI" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg") # pacman -Rns --noconfirm aur/pkg2

        if [[ $pkg =~ ^(aur\/) ]]; then
            POXI_remove=$(printf "%s -Rns %s %s" "$AHELPER" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg") # paru -Rns --noconfirm aur/pkg2
        fi
        eval ${POXI_remove}
        echo "$?"
    done
}

## get package information
get_package_detail() {
    local PKG=$1
    local Preview="$($POXI --color=always -Si $PKG)"
    echo "$Preview"
}

## get all packages name and return selected pkgs in one string
get_all_packages(){
    if test -n "$AHELPER" && test -v AHELPER; then
        local POXI_tool=$AHELPER
        local _sync=""
    else
        local POXI_tool=$POXI
        local _sync="--sync"
    fi
    local PKGS="$($POXI_tool --color=always -Sl \
    | fzf --ansi --multi $_sync \
    | awk '{s = s $1 "/" $2 " "} END {print s}')"
    echo $PKGS
}

## get all installed packages name and return selected pkgs in one string
get_installed_packages() {
    if test -n "$AHELPER" && test -v AHELPER; then
        local POXI_tool=$AHELPER
        local _sync=""
    else
        local POXI_tool=$POXI
        local _sync="--sync"
    fi
    local PKGS="$($POXI_tool --color=always -Qe \
    | fzf --ansi --multi $_sync \
    | awk '{s=s $1 " "} END{print s}')"
    echo $PKGS  
}

