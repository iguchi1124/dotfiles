# rbenv
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# go
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# llvm
export PATH="/usr/local/opt/llvm/bin:$PATH"

if [ -e "$HOME/.zshenv_local" ]; then
  source "$HOME/.zshenv_local"
fi
