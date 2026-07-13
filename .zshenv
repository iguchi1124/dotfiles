export EDITOR=vim

if [[ -f ~/.zshenv_local ]]; then
  source ~/.zshenv_local
fi

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
