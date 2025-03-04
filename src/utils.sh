#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_JSON_FILE=$ROOT_DIR/packages.json
HOME_PKG_JSON_FILE="${XDG_DATA_HOME:-$HOME}/base/packages.json"
PERU="pacman"

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
        sleep 2&
    done
    wait
    echo " installation done"
}

## get package information
get_package_detail() {
    local PKG=$1
    local Preview="$($PERU --color=always -Si $PKG)"
    echo "$Preview"
}

## get all packages name and return selected pkgs in one string
get_all_packages(){
    local PKGS="$($PERU --color=always -Sl \
    | head -n 5 \
    | fzf --ansi --multi --sync \
    | awk '{s = s $1 "/" $2 " "} END {print s}')"
    echo $PKGS
}

## get all installed packages name and return selected pkgs in one string
get_installed_packages() {
    local PKGS="$($PERU --color=always -Qe \
    | head -n 5 \
    | fzf --ansi --multi --sync \
    | awk '{s=s $1 " "} END{print s}')"
    echo $PKGS  
}

