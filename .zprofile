for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  if [[ -x $brew ]]; then
    eval "$($brew shellenv)"
    break
  fi
done

if [[ -f ~/.zprofile_local ]]; then
	source ~/.zprofile_local
fi
