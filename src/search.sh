pkg=$(pacman -Ss | awk -F'/' '{print $2}' | fzf --prompt="Search pacman packages: ")
[ -n "$pkg" ] && pacman -Si "$pkg"

echo $pkg