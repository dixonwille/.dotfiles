---
name: env-system
description: Environment variable configuration (systemd's environment.d, loaded by zsh too). Use when adding or changing environment variables, PATH entries, or files in environment.d.
user-invocable: false
---

# Environment Configuration

Every environment variable lives in `~/.config/environment.d/*.conf`, systemd's
format, the same as the work workstation's `env file`:

- `KEY=VALUE` lines and `#` comments; values expand `$VAR`, `${VAR}`,
  `${VAR:-default}` and `${VAR:+alternate}`, nothing else (no commands, no
  quotes).
- The systemd user manager reads them itself; `home/.zshenv` sources each one
  (`set -a`) for shells it didn't start (WSL terminals, macOS), in every zsh.
  So values can't contain spaces: lists use `:`.
- `.zshenv` runs `typeset -U path`, so prepending to `PATH` is safe when nested
  shells (tmux) source the files again.
- `~/.config/environment.d` stays a real directory (`./install` creates it before
  stowing): the workstation writes its env file there.

There's no shell-code environment layer: interactive setup goes in `.zshrc`.
XDG base directories are left unset (their defaults apply); configs read them
with the default as fallback, e.g. `${XDG_CONFIG_HOME:-$HOME/.config}`.

## Locations

| File | Purpose |
|------|---------|
| `home/.config/environment.d/999-path.conf` | `~/.local/bin` and `~/.cargo/bin` on PATH, every machine |
| `personal/work/.config/environment.d/60-dotfiles-work.conf` | Work's values (private submodule): Neovim's `DOTFILES_*` settings |
| `~/.config/environment.d/env file` | The workstation's (BROWSER, the Artifacts PAT, ...); not in the repo, never copy it in |

## File Naming

systemd reads every `environment.d` directory (`/usr/lib`, `/etc`, `~/.config`)
merged and sorted by file name, later files winning. Ubuntu's
`/usr/lib/environment.d/99-environment.conf` sets `PATH` outright, so a file
that changes `PATH` must sort after it (and snapd's `990-`): hence `999-path.conf`.
Other files: after `50-` (the workstation's) when they may build on its values.

## Adding a Variable

1. Add `KEY=value` to the right `.conf` (work-only: `personal/work`), with a
   comment saying what reads it
2. New shells pick it up; for systemd's copy (services), `systemctl --user daemon-reload`
