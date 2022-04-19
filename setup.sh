#!/bin/bash

set -e

TOOLS=(
  "git"
  "zsh"
)

for cmd in "${TOOLS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd is required to be installed."
    exit 1
  fi
done

if [ -z "$XDG_CONFIG_HOME" ]; then
  XDG_CONFIG_HOME="$HOME/.config"
fi

DOTPATH=$HOME/.dotfiles
if [ ! -d $DOTPATH ]; then
  git clone git@github.com:iguchi1124/dotfiles.git $DOTPATH
fi

mkdir -p $XDG_CONFIG_HOME
for config in $DOTPATH/.config/*
do
  ln -snfv $config $XDG_CONFIG_HOME
done

for file in ".tmux.conf" ".tmux.conf.wsl" ".vim" ".vimrc" ".zshrc" ".zshenv" ".zprofile"
do
  src="$DOTPATH/$file"
  ln -snfv $src $HOME
done

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone git@github.com:tmux-plugins/tpm.git $HOME/.tmux/plugins/tpm && $HOME/.tmux/plugins/tpm/bin/install_plugins
fi

if [ ! -d "$HOME/.zplug" ]; then
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi

if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

case "$(uname)" in
Darwin*)
  for file in ".Brewfile"
  do
    src="$DOTPATH/$file"
    ln -snfv $src $HOME
  done

  if ! command -v brew &> /dev/null; then
    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | zsh
  fi

  if [ ! $(brew tap | grep "homebrew/bundle") ]; then
    brew tap homebrew/bundle
  fi
  ;;
esac
