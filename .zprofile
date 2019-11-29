kjobs() {
  jobs -p | \
  gawk 'match($0, /\[[0-9]+\]\s*[\-\+]?\s*([0-9]+).*/, md) {print md[1]}' | \
  xargs -n1 pkill -SIGINT -g
}

[ -f ~/.zprofile_local ] && source ~/.zprofile_local
