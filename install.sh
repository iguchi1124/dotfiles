DOTPATH=$HOME/.dotfiles

for file in .??*; do
    [ $file == ".git" ] ||
    [ $file == ".gitignore" ] ||
    [ $file == ".gitmodules" ] &&
    continue

    ln -snfv "$DOTPATH/$file" "$HOME/$file"
done
