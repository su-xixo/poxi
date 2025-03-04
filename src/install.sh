#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

function add_to_json {
    local pkg=$1
    local check=$(jq --arg pkg "$pkg" '.installed|any(.==$pkg)' $PKG_JSON_FILE)
    printf "check is: %s\n" "$check"
    if [ $check == 'false' ]; then
        jq --arg pkg "$pkg" '.installed += [$pkg]' $PKG_JSON_FILE | sponge $PKG_JSON_FILE
    fi
}

install_pkg(){
    local pkgs=($@)
    echo "available packages to install: ${pkgs[@]}"
    for pkg in ${pkgs[@]}; do
        add_to_json $pkg
    done
}
install_pkg pkg1 pkg2 pkg3 pkg4 

