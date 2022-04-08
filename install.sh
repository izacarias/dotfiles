
# Install dotfile by creating symlinks
# LN_CMD=/usr/bin/ln -svf
CWD=$(pwd)

ln -sfv $CWD/vimrc $HOME/.vimrc 
ln -sfv $CWD/vim $HOME/.vim
ln -sfv $CWD/inkscape $HOME/.config/inkscape
