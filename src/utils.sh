#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_JSON_FILE=$ROOT_DIR/packages.json
HOME_PKG_JSON_FILE="${XDG_DATA_HOME:-$HOME}/base/packages.json"

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
    local pkg=$1
    if [ -z "$pkg" ] || [ $# -eq 0 ]; then
        echo "empty string"
        return
    fi
    read -n 1 -p "Want to preceed[Y/N]: " confirm
    local confirm="${confirm:-y}"
    confirm="${confirm,,}"
    if [[ "$confirm" == "n" ]]; then
        printf "󱠡 Bye Bye....\n"
        return
    fi
    printf "installing pakage $pkg\r"
    sleep 2
    echo "$pkg: Installation Done 󰩐"    
}
simmulate_install pkg1

# install package function
install_pkg(){
    check_json_file
    echo "installing packages"
}
install_pkg
