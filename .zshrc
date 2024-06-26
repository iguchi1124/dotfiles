source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build:"zplug --self-manage"

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

bindkey -e

setopt interactive_comments

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

PROMPT="%(?:%{$fg_bold[green]%}$ :%{$fg_bold[red]%}$ %s)%{$fg_bold[green]%}%p%{$fg[cyan]%}%c%{$reset_color%} "

# ls
alias ls='ls -GF'

# zsh-autosuggestions
bindkey '^l' autosuggest-accept

# rbenv
export RBENV_ROOT=$HOME/.rbenv
export PATH=$RBENV_ROOT/bin:$PATH

if command -v rbenv &> /dev/null; then
  eval "$(rbenv init - zsh)"
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT/bin ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv &> /dev/null; then
  eval "$(pyenv init -)"
fi

# luarocks
if command -v luarocks &> /dev/null; then
  eval "$(luarocks path --bin)"
fi

# go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# llvm
export PATH=/usr/local/opt/llvm/bin:$PATH

# fzf
if command -v fzf &> /dev/null; then
  eval "$(fzf --zsh)"
fi

# volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# homebrew
export PATH=/opt/homebrew/bin:$PATH

# .zshrc_local
if [[ -f ~/.zshrc_local ]]; then
  source ~/.zshrc_local
fi
