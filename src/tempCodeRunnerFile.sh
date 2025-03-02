ROOT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UTILS=$ROOT_DIR/src/utils.sh
source $UTILS
pkg="pk1"

jq --arg pkg "$pkg" '
  if .installed | index($pkg) == null then
    .installed += [$pkg]
  else
    .
  end
' $PKG_JSON_FILE | sponge $PKG_JSON_FILE

# jq --arg pkg "$pkg" 'del(.installed[.installed|index($pkg)])' $PKG_JSON_FILE

a=$(jq -r '.required.editor[], .required.terminal[]' $PKG_JSON_FILE)
b=($a)
echo ${b[@]}

# jq -r '.required | .. | strings' $PKG_JSON_FILE
a=$(jq -r '.required | to_entries | map(.value) | flatten | unique' $PKG_JSON_FILE)
b=($a)
echo ${#b[@]}

jq 'walk(if type == "array" then unique else . end)' $PKG_JSON_FILE | sponge $PKG_JSON_FILE




