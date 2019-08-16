source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "~/.zsh", from:local
zplug "mafredri/zsh-async"
zplug "sindresorhus/pure", use:pure.zsh, as:theme
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"

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
