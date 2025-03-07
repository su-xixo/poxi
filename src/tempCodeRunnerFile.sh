for helper in p; do
    if command -v "$helper" &>/dev/null; then
        AHELPER="$helper"
        break
    fi
done
if [[ ! -v $AHELPER ]]; then
    echo "dont exist"
fi
echo $AHELPER