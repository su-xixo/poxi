item="zyx"
eval "get_list_"${item:-"demo"}"() {
    echo $item
}"
eval get_list_"$item"