#!/bin/bash

set -ex

TOOLS=(
  "git"
  "brew"
)

for cmd in "${TOOLS[@]}"; do
  if ! command -v $cmd &> /dev/null; then
    echo "$cmd is required to be installed."
    exit 1
  fi
done

DOTPATH=$HOME/.dotfiles
if [ ! -d $DOTPATH ]; then
  git clone git@github.com:iguchi1124/dotfiles.git $DOTPATH
fi

for file in .config/**/* ".Brewfile" ".tmux.conf" ".zshrc" ".zshenv" ".zprofile"
do
  src="$DOTPATH/$file"
  dist="$HOME/$file"
  mkdir -p $(dirname $dist)
  if [ -f $src ] && [ ! -f $dist ]; then
    ln -snfv $src $dist
  fi
done

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
