#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

function add_to_json {
    local pkg=$1
    local check=$(jq --arg pkg "$pkg" '.installed|any(.==$pkg)' $PKG_JSON_FILE)
    if [ $check == 'false' ]; then
        jq --arg pkg "$pkg" '.installed += [$pkg]' $PKG_JSON_FILE | sponge $PKG_JSON_FILE
    fi
}
function log_non_installed {
    local pkg=$1
    local file=".temp.json"
    local new_object=$(printf '{"name": "%s"}' $pkg)
    echo "logged pkg is: $new_object"
    if [ ! -f "$file" ] || [ ! -s "$file" ]; then # no file or empty
        echo "{}" > $file
    fi
    jq --arg pkg "$pkg" '.not_installed = (
        if has("not_installed") then
            if .not_installed | type == "array" then
                .not_installed | .+= [$pkg] | unique | sort
            else
                .not_installed
            end
        else
            [] | .+=[$pkg]
        end
        )' $file > temp.json && mv temp.json $file
}

install_pkg(){
    local pkgs=($@)
    if [ ${#pkgs[@]} -eq 0 ]; then
        pkgs+=($(get_all_packages))
    fi

    for pkg in ${pkgs[@]}; do
        simmulate_install $pkg && is_installed=$? || is_installed=$?
        if test $is_installed -eq 0; then
            # echo "adding $pkg into json file"
            add_to_json $pkg
            
        else
            echo "$pkg not installed"
            log_non_installed $pkg
        fi
        
    done
}
install_pkg $@

