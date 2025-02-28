simmulate_install(){
    if [ $# -eq 0 ]; then
        echo "No packages specified."
        return
    fi 
    local packages=()
    for pkg in "$@"; do
        packages+=("$pkg")
    done
    echo "${packages[@]}"
    # Ask the user if they want to install all packages or install individually
    read -p "Do you want to install all packages without confirmation [Y/N]? " install_all
    local install_all="${install_all,,:-y}"  # Convert to lowercase

    if [[ "$install_all" == "y" ]]; then
        echo "Installing all packages..."
        for pkg in "${packages[@]}"; do
            printf "Installing package $pkg...\r"
            sleep 2  # Simulate installation process
            echo "$pkg: Installation Done 󰩐"
        done
    else
        for pkg in "${packages[@]}"; do
            read -p "Want to proceed with installing '$pkg' [Y/N]: " confirm
            local confirm="${confirm:-y}"
            confirm="${confirm,,}"
            
            if [[ "$confirm" == "n" ]]; then
                printf "󱠡 Skipping package $pkg...\n"
                continue
            fi
            
            printf "Installing package $pkg...\r"
            sleep 2
            echo "$pkg: Installation Done 󰩐"
        done
    fi
}
simmulate_install pkg1

