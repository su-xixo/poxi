 POXI=$(printf "pacman -S --needed %s %s" "$([[ "$ACCEPT_ALL" == "true" ]] && echo "--noconfirm" || echo "")" "$pkg")
        echo $POXI