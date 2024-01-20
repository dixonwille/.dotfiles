if [[ -n "$_DF_ZSH_ENV_SOURCED" ]]; then return; fi
export _DF_ZSH_ENV_SOURCED=1

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export DOTFILESDIR="$XDG_DATA_HOME/dotfiles"

(( $+commands[docker] )) && [[ "$(uname -r)" != *WSL2 ]] && export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

if [[ -d "$XDG_CONFIG_HOME/environment.d" ]]; then
  for e in $XDG_CONFIG_HOME/environment.d/*; do
    source "$e"
  done
fi
export PATH="$HOME/.local/bin:$PATH"
