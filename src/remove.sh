#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

function log {
    local action=$1
    shift 1
    local pkg=$1
    local file=".temp.json"
    local new_object=$(printf '{"name": "%s"}' $pkg)
    echo "logged pkg is: $new_object"
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then # no file or empty
        echo "{}" > $file
    fi
    
    jq ".$action = (
        if has(\"$action\") then
            if .$action | type == \"array\" then
                .$action | .+= [\"$pkg\"] | unique | sort
            else
                .$action
            end
        else
            [] | .+=[\"$pkg\"]
        end
    )" $file > temp.json && mv temp.json $file
}

remove_pkg(){
    local pkgs=($@)
    if [ ${#pkgs[@]} -eq 0 ]; then
        pkgs+=($(get_installed_packages))
    fi
    
    for pkg in ${pkgs[@]}; do
        printf "󰦗 Removing $pkg...\n"
        POXI_remove=$(printf "%s -Rns %s %s" "$POXI" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg") # pacman -Rns --noconfirm aur/pkg2

        if [[ $pkg =~ ^(aur\/) ]]; then
            POXI_remove=$(printf "%s -Rns %s %s" "$AHELPER" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg") # paru -Rns --noconfirm aur/pkg2
        fi
        eval $POXI_remove && is_removed=$? || is_removed=$?
        if [[ $is_removed == "0" ]]; then
            echo " $pkg removed"
            log removed $pkg
        fi
        
    done
}
# remove_pkg $@ # commented for main function

