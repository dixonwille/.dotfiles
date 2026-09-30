# Reminder while the Ghostty systemd override is known to be unnecessary

if [[ -e "${XDG_STATE_HOME:-$HOME/.local/state}/ghostty-override-check/fixed" ]]; then
  print -P "%F{yellow}ghostty: systemd override is no longer needed — run ghostty-override-check --remove%f"
fi
