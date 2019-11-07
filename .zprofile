killjobs() {
  jobs -p | \
  gawk 'match($0, /\[[0-9]+\]\s*[\-\+]?\s*([0-9]+).*/, md) {print md[1]}' | \
  xargs -n1 pkill -SIGINT -g
}

if [ -e "$HOME/.zprofile_local" ]; then
  source "$HOME/.zprofile_local"
fi
