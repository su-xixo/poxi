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
    if [ ${#pkgs[@]} -eq 0 ]; then
        pkgs+=($(get_all_packages))
    fi
    # echo "length of pkgs array is ${#pkgs[@]} and array is ${pkgs[@]}" 
    # return
    echo "available packages to install: ${pkgs[@]}"
    # TODO: get oneliner for is_installed
    simmulate_install ${pkgs[@]}
    is_installed=$(echo $?)
    echo "exit code for install command: $is_installed"
    if test $is_installed -eq 0; then
        
    fi
    
    return
    for pkg in ${pkgs[@]}; do
        add_to_json $pkg
    done
}
install_pkg pkg1 pkg2 pkg3

