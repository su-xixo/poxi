#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

install_pkg(){
    if [ ${#} -eq 0 ]; then
        # installation with fzf
        # ==> get list of packages
        local packages=($(get_all_packages))
        echo ${#packages[@]}
        for pkg in ${packages[@]}; do
            result="$(simmulate_install pkg)" && echo 0 || echo 1
            if [ $result -eq 0 ]; then
                jq '.installed | \
                if index($pkg) == null then \
                    .+=["$pkg"] \
                else \
                    empty
                end' $PKG_JSON_FILE
            fi
        done
        # $PERU -S $packages # package installer
    
    else
        # instllation without fzf
        local packages="$@"
        echo $packages
    fi


}
install_pkg "$@"

