#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL=$ROOT_DIR/bash/src/install.sh
UTILS=$ROOT_DIR/bash/src/utils.sh
source $INSTALL
source $UTILS
FILENAME=""


install_sim() {
    local pkgs=("$@")
    echo "install simulation"
    echo "packages are: ${pkgs[@]}"
}
remove_sim() { echo "remove simulation"; }
update_sim() { echo "update simulation"; }

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [COMMAND] [PACKAGES]

Mandatory options:
  -u, --username USERNAME    Specify username (required)
  
Other options:
  -h, --help                 Show this help message
  -b, --background           Execute in background
  -a, --accept-all           Accept all packages
  -f, --file fileame         Packages json file 

Command options:
  install [pkg [pkg pkg]]    Install packages
  remove  [pkg [pkg pkg]]    Remove packages
  update                     Update system
EOF
    exit 1
}


function main {
    # Capture remaining arguments after options are parsed
    local opts
    local short_options='bahf:'
    local long_options='background,accept-all,help,file:'
    if ! opts=$(getopt -o $short_options --long $long_options -n "$0" -- "$@"); then
        echo "Error: Invalid options passed!" >&2
        # usage
    fi
    eval set -- "$opts"
    while true; do
        case "$1" in
            -b|--background)
                BACKGROUND=true
                shift 1
                ;;
            -a|--accept-all)
                ACCEPT_ALL=true
                shift 1
                ;;
            -f|--file)
                FILENAME="$2"
                shift 2
                ;;
            -h|--help)
                usage
                ;;
            --)
                shift 1
                break
                ;;
            *)
                echo "Internal error while parsing options!" >&2
                exit 1
                ;;
        esac
    done
    echo $@

    # # Display configuration
    # echo "Runtime configuration:"
    # echo "----------------------"
    # echo "background: $BACKGROUND"
    # echo "accept-all: $ACCEPT_ALL"

    echo "$opts"
    # try regex to select only when their is no other 
    # parameter available after '--'
    if [ -z "$@" ]; then
        echo "$@"
        echo -e "$0 ${COLORS['yellow']}only script name.${COLORS['reset']}"
        exit 0
    fi

    case "$1" in
        install)
            shift 1
            if [[ -n "$FILENAME" ]]; then
                # mapfile -t installed_packages < <(jq -r '.installed[]' $PKG_JSON_FILE)
                local installed_packages=()
                while IFS= read -r pkg; do
                    installed_packages+=("$pkg")
                done < <(jq -r '.installed[]' $PKG_JSON_FILE)
                echo "installed packages: ${installed_packages[@]}"
                # install_sim "${installed_packages[@]}"
            else
                install_sim $@
            fi
            # install_pkg $@
            ;;
        remove)
            shift 1
            remove_sim
            ;;
        update)
            shift 1
            update_sim
            ;;
        *)
            echo "Unknown command"
            # install_sim $@
            # install_pkg $@
            shift 1
            ;;
    esac
    echo "Remaining arguments after parsing: $@"

}

# Execute main function
# main "$@"
# main -ba install pkg1 pkg2 pkg3
# main -f install install
# main -c
main -a 
