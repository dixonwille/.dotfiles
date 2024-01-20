if (( $+commands[zellij] )); then
  export ZELLIJ_AUTO_EXIT="true"
	eval "$(zellij setup --generate-auto-start zsh)"
fi
