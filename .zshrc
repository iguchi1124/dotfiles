export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  history-substring-search
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

# rbenv
export RBENV_ROOT=$HOME/.rbenv
export PATH=$RBENV_ROOT/bin:$PATH

if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi

# go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# llvm
if [[ -d /opt/homebrew/opt/llvm/bin ]]; then
  export PATH=/opt/homebrew/opt/llvm/bin:$PATH
elif [[ -d /usr/local/opt/llvm/bin ]]; then
  export PATH=/usr/local/opt/llvm/bin:$PATH
fi

# fzf
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

# homebrew
export PATH=/opt/homebrew/bin:$PATH

# mise
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# XDG
export PATH="$HOME/.local/bin:$PATH"

# .zshrc_local
if [[ -f ~/.zshrc_local ]]; then
  source ~/.zshrc_local
fi
