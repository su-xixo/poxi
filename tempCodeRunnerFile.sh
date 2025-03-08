main(){
    local desktop=$DESKTOP_SESSION
    if [[ $(jq 'has("Installed")' .tmp.json) == 'false' ]];then
        jq ".Installed={}" .tmp.json | sponge .tmp.json
    else
        jq ".Installed+={"gnome:{}"}" .tmp.json | sponge .tmp.json
        jq ".Installed+={"cinnamon:{}"}" .tmp.json | sponge .tmp.json
    fi
}
# main
desktop=$DESKTOP_SESSION
file=".tmp.json"

jq  "
    if has(\"Installed.$desktop\") == false then
        .Installed.$desktop={}
    else
        .
    end
" $file > temp.json && mv temp.json $file