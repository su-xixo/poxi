main(){
    read -p "this is example read: " a
    echo "this is value of a: $a"
    sudo pacman -S cowsay
}
main > /dev/null