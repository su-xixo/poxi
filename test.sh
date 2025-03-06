#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL=$ROOT_DIR/bash/src/install.sh
UTILS=$ROOT_DIR/bash/src/utils.sh
source $INSTALL
source $UTILS


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
    local short_options='bah'
    local long_options='background,accept-all,help'
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
                FILENAME=true
                shift 1
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
    
    # Display configuration
    echo "Runtime configuration:"
    echo "----------------------"
    echo "background: $BACKGROUND"
    echo "accept-all: $ACCEPT_ALL"

    case "$1" in
        install)
            shift 1
            # install_sim $@
            install_pkg $@
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
            # install_sim $@
            install_pkg $@
            shift 1
            ;;
    esac
    echo "Remaining arguments after parsing: $@"

}

# Execute main function
# main "$@"
main -ba install pkg1 pkg2 pkg3
