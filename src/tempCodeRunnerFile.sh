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

printf "(pacman cmd: %s) and (aur helper cmd: %s)\n" "$POXI" "$AHELPER"