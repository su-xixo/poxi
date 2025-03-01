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
simmulate_install(){
    if [ $# -eq 0 ]; then
        echo "No packages specified."
        return
    fi 
    local packages=()
    for pkg in "$@"; do
        packages+=("$pkg")
    done
    # Ask the user if they want to install all packages or install individually
    read -p "Do you want to install all packages without confirmation [Y/N/X]? " install_all
    local install_all="${install_all:-y}"
    install_all="${install_all,,}"

    if [ "$install_all" == "x" ]; then
        echo "Installation cancelled."
        exit 1
    fi

    if [[ "$install_all" == "y" ]]; then
        echo "Installing all packages..."
        for pkg in "${packages[@]}"; do
            printf "Installing package $pkg...\r"
            sleep 2
            echo "$pkg: Installation Done 󰩐"
        done
    else
        for pkg in "${packages[@]}"; do
            read -p "Want to proceed with installing '$pkg' [Y/N]: " confirm
            local confirm="${confirm:-y}"
            confirm="${confirm,,}"
            
            if [[ "$confirm" == "n" ]]; then
                printf "󱠡 Skipping package $pkg...\n"
                continue
            fi
            
            printf "Installing package $pkg...\r"
            sleep 1
            echo "$pkg: Installation Done 󰩐"
        done
    fi
}
# result=$(simmulate_install pkg1 pkg2 > /dev/null) && echo 0 || echo 1
# echo $result

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
    | awk '{s = s $1 "/" $2 " "} END {print s}')"
    echo $PKGS
}

# install package function
install_pkg(){
    # check_json_file
    echo "installing packages"
    # ==> get list of packages
    # sudo pacman --color=always -Sl | head -n 5 | fzf --ansi --multi --sync | awk '{s = s $1 "/" $2 " "} END {print s}'
    
    
}
# install_pkg
