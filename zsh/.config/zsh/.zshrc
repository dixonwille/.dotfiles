mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
# Lines configured by zsh-newuser-install
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt extendedglob notify SHARE_HISTORY
unsetopt autocd beep nomatch
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename "${ZDOTDIR:-$HOME}/.zshrc"

autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# End of lines added by compinstall

# Commone Environment
export EDITOR="nvim"
export MANPAGER='nvim +Man!'

if [ -r "$HOME/.config/zsh/.zshrc_work" ]; then
  source "$HOME/.config/zsh/.zshrc_work"
fi

# Get into tmux easier
bindkey -s '^f' "tmux-sessionizer\n"

# History search
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Plugins
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
ZSH_PLUGINS=${XDG_DATE_HOME:-$HOME/.local/share}/zsh/plugins
if [ -d "$ZSH_PLUGINS" ]; then
  source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
if command -v oh-my-posh >/dev/null 2>&1; then
  eval "$(oh-my-posh init zsh --config "${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-posh/theme.omp.json")"
fi

# Completions
if command -v jj >/dev/null 2>&1; then
  source <(COMPLETE=zsh jj)
fi

# Aliases
alias vim="nvim"
if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
  alias lla="ls -la"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi
