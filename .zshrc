export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  brew
  git
  fzf
  history-substring-search
  mise
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [[ -d $ZSH ]]; then
  fpath+="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src"

  source $ZSH/oh-my-zsh.sh
fi

# fzf
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p 80%"

# ls
alias ls='ls -GF'

# go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# .zshrc_local
if [[ -f ~/.zshrc_local ]]; then
  source ~/.zshrc_local
fi
