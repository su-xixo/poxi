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
    local file=".temp.json"
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

# check for insatalled packages
check_package_installed() {
  local package_name="$1" # extra/bat
  package_name=${package_name##*/} # trim longest pattern match O/P: bat
  pacman -Q "$package_name" &>/dev/null  # Suppress output
  if [[ $? -eq 0 ]]; then
    echo "Package '$package_name' is installed."
    return 0 # Return success
  else
    echo "Package '$package_name' is NOT installed."
    return 1 # Return failure
  fi
}


generate_cmd() {
    local options needed accept_all pkgs
    options="$1" # '-S'
    needed="${2:-true}" # 'true', 'false'
    accept_all="${3:-true}" # 'true', 'false'
    pkgs=(${@:4}) # array

    if [ $needed == 'true' ]; then
        needed=" --needed"
    else
        needed=""
    fi
    if [ $accept_all == 'true' ]; then
        accept_all=" --noconfirm"
    else
        accept_all=""
    fi

    # extract aur packages from pkgs and store into POXI_aur_install
    local POXI_aur_install=() # store aur packages
    local POXI_install=() # store official packages
    for pkg in ${pkgs[@]}; do
        if [[ $pkg =~ ^(aur\/) ]]; then
            POXI_aur_pkgs+=("$pkg")
        else
            POXI_official_pkgs+=("$pkg")
        fi
    done

    [ ${#POXI_official_pkgs[@]} -ne 0 ] && local command_string_for_official_packages="$POXI $options$needed$accept_all ${POXI_official_pkgs[@]}"
    [ ${#POXI_aur_pkgs[@]} -ne 0 ] && local command_string_for_aur_packages="$AHELPER $options$needed$accept_all ${POXI_aur_pkgs[@]}"
    printf "%s\n" "$command_string_for_official_packages" "$command_string_for_aur_packages"
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

install_pkg $@