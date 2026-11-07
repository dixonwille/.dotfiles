# Interactive zsh. Order matters: completion setup before anything that calls
# compdef, keybinds before the work overrides that may rebind them, mise after
# them (it adapts to whether they hooked direnv), and the plugins last, since
# zsh-syntax-highlighting wraps every widget defined before it.

# Options and history -----------------------------------------------------------

mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt extendedglob notify SHARE_HISTORY
unsetopt autocd beep nomatch
bindkey -v

# Completion ---------------------------------------------------------------------

# The nix profile's completions, ahead of the system's. Here rather than in
# .zshenv: fpath isn't exported, so it belongs with the interactive setup.
if [ -d "$HOME/.nix-profile/share/zsh/site-functions" ]; then
  fpath=("$HOME/.nix-profile/share/zsh/site-functions" $fpath)
fi
autoload -Uz compinit
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

# Environment --------------------------------------------------------------------

# Variables are in environment.d (see .zshenv); this one has a space, which that
# format can't hold.
export MANPAGER='nvim +Man!'

# Interactive-only snippets (e.g. rc.d/osc7.zsh, the terminals' cwd reporting)
for rc_file in "$ZDOTDIR/rc.d"/*.zsh(N); do
  . "$rc_file"
done
unset rc_file

# Widgets and keybinds -------------------------------------------------------------

# Jump to a project. Runs a real `cd` so prompt hooks and history see it.
project-cd() {
  local dir
  dir=$(project-list | fzf --height=40% --reverse) || { zle reset-prompt; return }
  BUFFER="cd ${(q)dir}"
  zle accept-line
}
zle -N project-cd
bindkey -M viins '^f' project-cd
bindkey -M vicmd '^f' project-cd

# History search on the arrow keys, by what's typed so far
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# Work overrides, from the private submodule when that machine gets them. After
# the keybinds, so they can rebind them.
if [ -r "$ZDOTDIR/.zshrc_work" ]; then
  source "$ZDOTDIR/.zshrc_work"
fi

# Each project's tools, from its mise.toml. mise doesn't support running beside
# direnv (both rewrite PATH at each prompt, and can undo each other's entries),
# which a machine's own setup may already have hooked (the work overrides
# above), for repos that commit an .envrc. So:
# - where direnv is hooked, mise stays out of the prompt: its shims go last on
#   PATH, so they only fill in what nothing else provides (e.g. editor tools
#   from a parent directory's mise.toml), and each resolves its version from the
#   directory it runs in. direnv's and the machine's own tools come first.
#   mise.toml's [env] isn't applied there.
# - everywhere else, mise activate: tools and [env] follow each prompt.
if command -v mise >/dev/null 2>&1; then
  if (( ${+functions[_direnv_hook]} )); then
    path+=("${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims")
  else
    eval "$(mise activate zsh)"
  fi
fi

# Prompt ---------------------------------------------------------------------------

if command -v oh-my-posh >/dev/null 2>&1; then
  # init caches its script under a name that ignores the binary's path, so a nix
  # rebuild at the same version keeps calling the old, garbage-collected binary.
  # Drop any cached script that doesn't call this one; init writes a new one.
  for f in "${XDG_CACHE_HOME:-$HOME/.cache}"/oh-my-posh/init.*.zsh(N); do
    grep -qF -- "${commands[oh-my-posh]:A}" "$f" || rm -f -- "$f"
  done
  unset f
  eval "$(oh-my-posh init zsh --config "${XDG_CONFIG_HOME:-$HOME/.config}/oh-my-posh/theme.omp.json")"
fi

# Completions that need compinit ---------------------------------------------------

if command -v jj >/dev/null 2>&1; then
  source <(COMPLETE=zsh jj)
fi

# Aliases --------------------------------------------------------------------------

alias vim="nvim"
if command -v eza >/dev/null 2>&1; then
  alias ls="eza"
  alias lla="ls -la"
fi
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
fi

# Plugins, last ----------------------------------------------------------------------

# zsh-syntax-highlighting has to come after every widget and keybind (it wraps the
# ones that exist when it loads), and autosuggestions before it.
ZSH_PLUGINS=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins
if [ -d "$ZSH_PLUGINS" ]; then
  source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$ZSH_PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
