#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

# version 0.1: without desktop environment
function add_to_json {
    local pkg=$1
    local check=$(jq --arg pkg "$pkg" '.installed|any(.==$pkg)' $PKG_JSON_FILE)
    if [ $check == 'false' ]; then
        jq --arg pkg "$pkg" '.installed += [$pkg]' $PKG_JSON_FILE | sponge $PKG_JSON_FILE
    fi
}

# version 0.2: with desktop environment
function add_to_json {
    local pkg=$1
    local check=$(jq --arg pkg "$pkg" '.installed|any(.==$pkg)' $PKG_JSON_FILE)
    if [ $check == 'false' ]; then
        jq --arg pkg "$pkg" '.installed += [$pkg]' $PKG_JSON_FILE | sponge $PKG_JSON_FILE
    fi
    jq "
        if has(\"poxi_installed\") then
            .poxi_installed.$DESKTOP |= (. // [])
        else
            . + {\"poxi_installed\": {$DESKTOP: []}}
        end
    " $PKG_JSON_FILE > temp.json && mv temp.json $PKG_JSON_FILE

    jq ".poxi_installed.$DESKTOP+=[\"$pkg\"]" $PKG_JSON_FILE > temp.json && mv temp.json $PKG_JSON_FILE
    jq ".poxi_installed.$DESKTOP |= unique" $PKG_JSON_FILE > temp.json && mv temp.json $PKG_JSON_FILE
}

function log_non_installed {
    local pkg=$1
    local file="$HOME_TMP_JSON_FILE"
    local new_object=$(printf "%s" "$pkg")
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

# new install approach 
install_pkg(){
    local pkgs=($@)
    if [ ${#pkgs[@]} -eq 0 ]; then
        pkgs+=($(get_all_packages))
    fi
    IFS=$'\n' read -d '' -a POXI_install <<<"$(generate_cmd '-S' 'true' 'true' "${pkgs[@]}")"
    for cmd in "${POXI_install[@]}"; do
        eval "$cmd"
    done
    for pkg in "${pkgs[@]}"; do
        check_package_installed $pkg
        [ $? -eq 0 ] && add_to_json $pkg || log_non_installed $pkg
    done
}

# install_pkg $@