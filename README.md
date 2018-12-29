# Dotfiles

## Setup

```
git clone git@github.com:iguchi1124/dotfiles.git ~/.dotfiles --recursive
cd ~/.dotfiles && ./install
```

### Install dein.vim
```
curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh
sh ./installer.sh ~/.cache/dein
```

```
:call dein#install()
```

see https://github.com/Shougo/dein.vim

### Install homebrew
```
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap Homebrew/bundle
brew bundle
```

see https://brew.sh and https://github.com/Homebrew/homebrew-bundle
