# history
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history

# plugins (Homebrew)
if [[ -n $HOMEBREW_PREFIX ]]; then
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# zsh-completions
if [[ -n $HOMEBREW_PREFIX ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh-completions" "$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit && compinit

# fzf
if command -v fzf &> /dev/null; then
  export FZF_TMUX=1
  export FZF_TMUX_OPTS="-p 80%"

  source <(fzf --zsh)
fi

# mise
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# ls
alias ls='ls -GF'

# go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# prompt
setopt prompt_subst
git_prompt_info() {
  local ref
  ref=$(git symbolic-ref --short HEAD 2>/dev/null) ||
    ref=$(git rev-parse --short HEAD 2>/dev/null) || return 0
  local suffix="%F{blue})"
  if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
    suffix="%F{blue}) %F{yellow}✗"
  fi
  print -rn -- "%B%F{blue}git:(%F{red}${ref}${suffix}%f%b "
}
PROMPT='%(?:%B%F{green}➜%f%b :%B%F{red}➜%f%b ) %F{cyan}%c%f $(git_prompt_info)'

# .zshrc_local
if [[ -f ~/.zshrc_local ]]; then
  source ~/.zshrc_local
fi
