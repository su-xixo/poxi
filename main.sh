#!/bin/bash
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