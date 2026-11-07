export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# Each directory on PATH once, keeping the first: the files below prepend to
# PATH, and nested shells (tmux) source them again
typeset -U path PATH

# The environment: plain variables in systemd's environment.d format (KEY=VALUE,
# with only $VAR expansion), as the workstation's env file. The systemd
# user manager reads them itself; shells it didn't start (WSL terminals, macOS)
# load them here. The shell sources each file, so values can't contain spaces or
# quotes: lists use ":".
for env_file in "${XDG_CONFIG_HOME:-$HOME/.config}"/environment.d/*.conf(N); do
  set -a
  . "$env_file"
  set +a
done
unset env_file
