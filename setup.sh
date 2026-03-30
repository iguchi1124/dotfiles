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
TPM_REPO="${TPM_REPO:-https://github.com/tmux-plugins/tpm.git}"

if [[ ! -d $DOTPATH ]]; then
  git clone "$DOTFILES_REPO" $DOTPATH
fi

mkdir -p $XDG_CONFIG_HOME
for config in $DOTPATH/.config/*
do
  ln -snfv $config $XDG_CONFIG_HOME
done

for file in ".tmux.conf" ".tmux.conf.*" ".vimrc" ".zshrc" ".zshenv" ".zprofile"
do
  src="$DOTPATH/$file"
  ln -snfv $src $HOME
done

if [[ -L "$HOME/.vim" && "$(readlink "$HOME/.vim")" == "$DOTPATH/.vim" ]]; then
  rm "$HOME/.vim"
fi

mkdir -p "$HOME/.vim"
ln -snfv "$DOTPATH/.vim/after" "$HOME/.vim/after"

if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  git clone "$TPM_REPO" $HOME/.tmux/plugins/tpm && $HOME/.tmux/plugins/tpm/bin/install_plugins
fi

if [[ ! -d "$HOME/.zplug" ]]; then
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
fi

if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

if ! command -v volta &> /dev/null; then
  curl -fsSL https://get.volta.sh | bash
fi

case "$(uname)" in
Darwin*)
  for file in ".Brewfile"
  do
    src="$DOTPATH/$file"
    ln -snfv $src $HOME
  done

  if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [[ ! $(brew tap | grep "homebrew/bundle") ]]; then
    brew tap homebrew/bundle
  fi
  ;;
esac
