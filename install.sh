# Install dotfile by creating symlinks
#
# LN_CMD=/usr/bin/ln -svf
CWD=$(pwd)

# Files to install
dotfiles=(
    "vimrc,.vimrc" 
    "vim,.vim"
    "inkscape,.config/inkscape"
    "starship.toml,.config/starship.toml"
    "bashrc,.bashrc"
    "bashrc.d,.bashrc.d"
);

create_links_fake () {
    for files in ${dotfiles[@]}; do
        curr=$files;
        OLDIFS=$IFS;
        IFS=',';
        set -- $curr;
        echo "Creating symlink $1 -> $2";
        # add current working directory to the path
        $1 = $CWD/$1
        $2 = $HOME/$2
        ln -sfv $1 $2; 
        IFS=$OLDIFS;
    done;
}

echo "Current directory is: $CWD"
echo "Destination directory (HOME) is: $HOME"
echo "Proceed with the symbolic linking dotfiles? (Press y to proceed)"
read -n 1 key <&1

if [[ $key = y ]]; then
    printf "\nCreating links...\n";
    create_links_fake;
    printf "\n\nDone!\n";
else
    printf "\n\nQuitting the script.\n";
fi
