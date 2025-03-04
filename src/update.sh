#!/bin/bash

ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS

update_pkg() {
    start_time=$(date +%s)
    sudo $POXI -Syyu
    wait
    end_time=$(date +%s)
    # total_time=$((end_time-start_time))
    total_time=$(echo | awk "{print $end_time-$start_time}")

    # Calculate hours, minutes, and seconds
    hours=$((total_time / 3600))
    minutes=$(( (total_time % 3600) / 60))
    seconds=$((total_time % 60))
    printf "${COLORS['blue']}:: 󰚰 ${COLORS['green']}Update takes total: %02d:%02d:%02d${COLORS['reset']}\n" $hours $minutes $seconds

}
update_pkg