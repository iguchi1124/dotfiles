#!/bin/bash

set -e

TOOLS=(
  "curl"
  "git"
  "zsh"
)

for cmd in "${TOOLS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd is required to be installed."
    exit 1
  fi
done

if [[ -z "$XDG_CONFIG_HOME" ]]; then
  XDG_CONFIG_HOME="$HOME/.config"
fi

DOTPATH=$HOME/.dotfiles
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/iguchi1124/dotfiles.git}"

if [[ ! -d $DOTPATH ]]; then
  git clone "$DOTFILES_REPO" $DOTPATH
fi

mkdir -p $XDG_CONFIG_HOME
# Create real directories and link files individually, so apps can keep
# runtime files (logs, sockets, caches) next to the managed config.
for config in $DOTPATH/.config/*
do
  name="$(basename "$config")"
  target="$XDG_CONFIG_HOME/$name"

  if [[ -L "$target" ]]; then
    rm "$target"
  fi
  mkdir -p "$target"

  for file in "$config"/*
  do
    ln -snfv "$file" "$target"
  done
done

for file in ".zshrc" ".zshenv" ".zprofile"
do
  src="$DOTPATH/$file"
  ln -snfv "$src" "$HOME"
done

if [[ ! -f "$XDG_CONFIG_HOME/vim/autoload/plug.vim" ]]; then
  curl -fLo "$XDG_CONFIG_HOME/vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

case "$(uname)" in
Darwin*)
  for file in ".Brewfile"
  do
    src="$DOTPATH/$file"
    ln -snfv "$src" "$HOME"
  done

  if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  ;;
esac
