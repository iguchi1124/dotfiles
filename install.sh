DOTPATH=~/.dotfiles

for file in .??*
do
    [ "$file" == ".git" ] || [ "$file" == ".gitignore" ] || [ "$file" == ".gitmodules" ] || [ $file == ".DS_Store" ] && continue
    ln -snfv "$DOTPATH/$file" "$HOME/$file"
done
