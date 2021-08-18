#!/bin/bash

set -e

TOOLS=(
  "brew"
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
MACOS_CONFIG="$DOTPATH/macos"

for config in $MACOS_CONFIG/.config/*
do
  echo $MACOS_CONFIG
  ln -snfv $config $XDG_CONFIG_HOME
done

for file in ".Brewfile"
do
  src="$MACOS_CONFIG/$file"
  ln -snfv $src $HOME
done

if [ ! $(brew tap | grep "homebrew/bundle") ]; then
  brew tap homebrew/bundle
fi
