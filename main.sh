#!/bin/bash
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"
SCRIPT_NAME="$(basename $0)"

## ==> sourcing all scripts <==
sh_files=()
# for file in $SCRIPT_DIR/*.sh; do
#     # Check if the file exists (in case there are no .sh files)
#     if [ -f "$file" ]; then
#         file=$(basename $file)
#         sh_files+=("$file")  # Append to the array
#     fi
# done

# echo this array is ${sh_files[@]}
# for item in ${sh_files[@]}; do
#     echo $item
# done

ignore_sh_files=("init.sh" "test.sh")

for item in $(find $SCRIPT_DIR -name "*.sh" -type f -exec basename {} \;); do 
    # # with ignore_sh_file to ignore files
    # for i in $ignore_sh_files; do
    #     if ["$SCRIPT_DIR/$item" == "$SCRIPT_DIR/$SCRIPT_NAME"]; then
    #         exit 0
    #     elif [ "$SCRIPT_DIR/$item" == "$SCRIPT_DIR/$i" ]; then
    #         exit 0
    #     elif [ -f "$SCRIPT_DIR/$item" ]; then
    #         echo "$item"
    #     fi
    # done

    # with 'ignore_' as prefix to filename
    if [[ ! "$item" =~ ^(ignore.*\.sh|temp.*\.sh|$SCRIPT_NAME)$ ]]; then
        # echo "$item"
        source "$SCRIPT_DIR/$item"
    fi
    
done

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/scripts"
source $SCRIPTS_PATH/themes.sh
source $SCRIPTS_PATH/utils.sh