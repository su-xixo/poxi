#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

function log {
    local action=$1
    shift 1
    # if want O/P: extra/pkg
    local pkg=$1
    # if want O/P: pkg
    if [[ "$pkg" =~ ^[a-z]*/ ]]; then # when 'alphabats/' contains
        pkg=$(echo $pkg | awk -F "/" '{s=s $2 " "} END{print s}') # O/P: pkg
    fi
    local file="$HOME_TMP_JSON_FILE"
    local new_object=$(printf "%s" "$pkg")
    echo -e "logged pkg is: ${COLORS['yellow']}$new_object${COLORS['reset']}"
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
    IFS=$'\n' read -d '' -a POXI_remove <<<"$(generate_cmd '-Rns' 'false' 'false' "${pkgs[@]}")"
    for cmd in "${POXI_remove[@]}"; do
        eval "$cmd"
    done
    for pkg in "${pkgs[@]}"; do
        check_package_installed $pkg
        [ $? -eq 1 ] && log removed $pkg
    done
}
# remove_pkg $@ # commented for main function

