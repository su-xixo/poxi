#!/bin/bash
# COMMAND NAME: POXI
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$CURRENT_DIR/src"
SCRIPT_NAME="$(basename $0)"

## ==> sourcing all scripts <==
sh_files=()

for item in $(find $SCRIPT_DIR -name "*.sh" -type f -exec basename {} \;); do 
    # with 'ignore_' as prefix to filename
    if [[ ! "$item" =~ ^(ignore.*\.sh|temp.*\.sh|$SCRIPT_NAME)$ ]]; then
        source "$SCRIPT_DIR/$item"
    fi
    
done

# ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# INSTALL=$ROOT_DIR/bash/src/install.sh
# REMOVE=$ROOT_DIR/bash/src/remove.sh
# UPDATE=$ROOT_DIR/bash/src/update.sh
# UTILS=$ROOT_DIR/bash/src/utils.sh
# source $INSTALL
# source $REMOVE
# source $UPDATE
# source $UTILS
FILENAME=""

usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [COMMAND] [PACKAGES]

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
                if [[ -f $FILENAME ]]; then
                    echo "file name is : $FILENAME"
                else
                    printf "${COLORS['red']}Error:${COLORS['reset']} '%s' is invalid file name.\n\t-f option require valid file name.\n" "$FILENAME" >&2
                    exit 1
                fi
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

    case "$1" in
        install)
            shift 1
            if [[ -n "$FILENAME" && -f "$FILENAME" ]]; then
                if [[ "$(jq -r 'has("installed") and (.installed | length != 0)' "$FILENAME")" == 'true' ]]; then
                    local installed_packages=()
                    while IFS= read -r pkg; do
                        installed_packages+=("$pkg")
                    done < <(jq -r '.installed[]' $FILENAME)
                    echo "installed packages: ${installed_packages[@]}"
                    # install_sim "${installed_packages[@]}"
                    install_pkg ${installed_packages[@]}
                fi
            else
                # install_sim $@
                install_pkg $@
            fi
            ;;
        remove)
            shift 1
            if [[ -n "$FILENAME" && -f "$FILENAME" ]]; then
                if [[ "$(jq -r 'has("installed") and (.installed | length != 0)' "$FILENAME")" == 'true' ]]; then
                    local removed_packages=()
                    while IFS= read -r pkg; do
                        removed_packages+=("$pkg")
                    done < <(jq -r '.installed[]' $FILENAME)
                    echo "removed packages: ${removed_packages[@]}"
                    # remove_pkg "${installed_packages[@]}"
                fi
            else
                # remove_sim $@
                remove_pkg $@
            fi
            ;;
        update)
            shift 1
            update_pkg
            ;;
        *)
            echo "Unknown command"
            shift 1
            ;;
    esac

}

main $@