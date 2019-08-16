source ~/.zplug/init.zsh

zplug "zplug/zplug", hook-build:"zplug --self-manage"

zplug "chrissicool/zsh-256color"
zplug "mafredri/zsh-async"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"

zplug "~/.zsh", from:local
zplug "~/.zsh/local", from:local

if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

zplug load

HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
