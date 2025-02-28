simmulate_install(){
    local pkg=$1
    if [ -z "$pkg" ] || [ $# -eq 0 ]; then
        echo "empty string"
        return
    fi
    read -n 1 -p "Want to preceed[Y/N]: " confirm
    local confirm="${confirm:-y}"
    confirm="${confirm,,}"
    if [[ "$confirm" == "n" ]]; then
        printf "󱠡 Bye Bye....\n"
        return
    fi
    printf "installing pakage $pkg\r"
    sleep 2
    echo "$pkg: Installation Done 󰩐"    
}
simmulate_install pkg1