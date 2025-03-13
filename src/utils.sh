#!/bin/bash

# colors
declare -A COLORS=(
    ["red"]="\e[31m"
    ["green"]="\e[32m"
    ["yellow"]="\e[33m"
    ["blue"]="\e[34m"
    ["magenta"]="\e[35m"
    ["cyan"]="\e[36m"
    ["white"]="\e[37m"
    ["reset"]="\e[0m"
)

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_JSON_FILE=$ROOT_DIR/packages.json
HOME_PKG_JSON_FILE="${XDG_DATA_HOME:-$HOME}/poxi/packages.json"
HOME_TMP_JSON_FILE="${XDG_DATA_HOME:-$HOME}/poxi/.temp.json"
if [ ! -d "$(dirname $HOME_TMP_JSON_FILE)" ]; then
    mkdir -p "$(dirname $HOME_TMP_JSON_FILE)"
fi
PKG_JSON_FILE=$HOME_PKG_JSON_FILE
# desktop name
DESKTOP=$DESKTOP_SESSION
# check if root
if [[ $EUID -eq 0 ]]; then
    POXI="pacman"
    is_root=true
else
    POXI="sudo pacman"
    is_root=false
fi
# set aur helper
for helper in paru yay; do
    if command -v $helper &>/dev/null; then
        AHELPER=$helper
        break
    fi
done

# printf "(pacman cmd: %s) and (aur helper cmd: %s)\n" "$POXI" "$AHELPER"

ACCEPT_ALL=false

check_json_file(){
    data='
    {
        "required": {
            "editor": ["neovim", "helix", "micro"],
            "terminal": ["alacritty", "kitty"],
            "utilites": ["moreutils", "fzf", "eza", "zoxide", "zsh"]
        },
        "installed": []
    }
    '
    if [[ -f "$PKG_JSON_FILE" ]]; then
        return
    else
        echo "Creating $(basename $PKG_JSON_FILE) file."
        echo "At location: $PKG_JSON_FILE"
        local dir_PKG_JSON_FILE="$(dirname $PKG_JSON_FILE)"
        mkdir -p "${dir_PKG_JSON_FILE}"
        result=$(echo "$data" | jq '.' > $PKG_JSON_FILE)
    fi
}

# get package information
get_package_detail() {
    local PKG=$1
    local Preview="$($POXI --color=always -Si $PKG)"
    echo "$Preview"
}

# get all packages name and return selected pkgs in one string
get_all_packages(){
    if test -n "$AHELPER" && test -v AHELPER; then
        local POXI_tool=$AHELPER
        local _sync=""
    else
        local POXI_tool=$POXI
        local _sync="--sync"
    fi
    local PKGS="$($POXI_tool --color=always -Sl \
    | fzf --ansi --multi $_sync \
    --border --padding 1,2 \
    --cycle \
    --layout=reverse \
    --border-label ' POXI ' \
    --preview "echo {2} | xargs -ro $POXI_tool -Si --color=always" \
    | awk '{s = s $1 "/" $2 " "} END {print s}')"
    echo $PKGS
}

# get all installed packages name and return selected pkgs in one string
get_installed_packages() {
    if test -n "$AHELPER" && test -v AHELPER; then
        local POXI_tool=$AHELPER
        local _sync=""
    else
        local POXI_tool=$POXI
        local _sync="--sync"
    fi
    local PKGS="$($POXI_tool --color=always -Qe \
    | fzf --ansi --multi $_sync \
    --border --padding 1,2 \
    --cycle \
    --layout=reverse \
    --border-label ' POXI ' \
    --preview "echo {1} | xargs -ro $POXI_tool -Si --color=always" \
    | awk '{s=s $1 " "} END{print s}')"
    echo $PKGS  
}

# check for insatalled packages
check_package_installed() {
  local package_name="$1" # extra/bat
  package_name=${package_name##*/} # trim longest pattern match O/P: bat
  pacman -Q "$package_name" &>/dev/null  # Suppress output
  if [[ $? -eq 0 ]]; then
    echo -e "${COLORS['blue']}:: 󱧘 ${COLORS['green']}Package '$package_name' is installed.${COLORS['reset']}"
    return 0 # Return success
  else
    echo -e "${COLORS['blue']}:: 󱧙 ${COLORS['green']}Package '$package_name' is NOT installed.${COLORS['reset']}"
    return 1 # Return failure
  fi
}

# generate command for install and remove
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
    if [ $ACCEPT_ALL == 'true' ]; then
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


