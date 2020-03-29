#!/bin/bash

set -e

DOTPATH=$HOME/.dotfiles

for file in ".Brewfile" ".config/nvim/init.vim" ".gemrc" ".gitconfig" ".gitignore_global" ".tmux.conf" ".zshrc" ".zshenv" ".zprofile"
do
  src="$DOTPATH/$file"
  dist="$HOME/$file"
  mkdir -p $(dirname $dist)
  if [ -f $src ] && [ ! -f $dist ]; then
    ln -snfv $src $dist
  fi
done

if [ ! -x "$(command -v brew)" ]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

if [ ! $(brew tap | grep "homebrew/bundle") ]; then
  brew tap homebrew/bundle
fi

brew bundle check --global || brew bundle install --global

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  git clone git@github.com:tmux-plugins/tpm.git $HOME/.tmux/plugins/tpm && $HOME/.tmux/plugins/tpm/bin/install_plugins
fi

if [ ! -d "$HOME/.zplug" ]; then
  export ZPLUG_HOME=$HOME/.zplug
  git clone git@github.com:zplug/zplug.git $ZPLUG_HOME
fi

if [ ! -f "$HOME/.local/share/nvim/site/autoload/plug.vim" ]; then
  curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi