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
  eval "$(rbenv init -)"
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
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# .zshrc_local
[ -f ~/.zshrc_local ] && source ~/.zshrc_local
