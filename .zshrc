export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  brew
  git
  fzf
  history-substring-search
  mise
  rbenv
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [[ -d $ZSH ]]; then
  fpath+="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src"

  source $ZSH/oh-my-zsh.sh
fi

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# ls
alias ls='ls -GF'

# go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# XDG
export PATH="$HOME/.local/bin:$PATH"

# .zshrc_local
if [[ -f ~/.zshrc_local ]]; then
  source ~/.zshrc_local
fi
