# Packages Reference

There are no per-app packages: `home/` mirrors `$HOME` and is the one public
stow package, stowed on every machine by `./install`. What differs by machine is
decided at runtime by the configs themselves, or by `./install`'s glue.

## What's in `home/`

| Path | Purpose |
|------|---------|
| `.local/bin/` | Custom scripts (project-list, tmux-sessionizer) |
| `.local/share/zsh/plugins/` | Zsh plugin submodules |
| `.config/ghostty/` | Ghostty terminal config (Linux and macOS desktops) |
| `.config/git/` | Git configuration, global ignore |
| `.config/jj/` | Jujutsu config |
| `.config/mise/` | mise's global settings only; tools are per project |
| `.config/nix/`, `.config/direnv/` | `nix.conf`; direnv's settings (where a machine's own setup brings direnv) |
| `.config/nvim/` | Neovim configuration |
| `.config/oh-my-posh/` | Shell prompt theme |
| `.config/tmux/` | tmux configuration |
| `.config/wezterm/` | WezTerm config (Windows, for WSL; `./install` points Windows at it) |
| `.config/zsh/`, `.zshenv` | Zsh configuration (`rc.d/osc7.zsh`: cwd reporting for the terminals) |
| `.ssh/` | SSH config; uses 1Password's agent wherever its socket exists |

## Private Packages (`personal/` submodule)

`personal/` is its own stow directory, always stowed `--no-folding` (it only
adds files to directories `home/` already has).

| Package | Purpose | Stowed |
|---------|---------|--------|
| `base` | Personal identity: git's `personal-config`, jj's `01-personal.toml` | Every machine |
| `work` | The work layer: identity, `.zshrc_work`, environment and editor tools for work (see the submodule's own skill) | Where `personal/install` decides (the work machine) |

`personal/nvim/spell/` isn't a package: `DOTFILES_SPELLFILE` names the work word list by its path.

## Support Directories

| Directory | Purpose |
|-----------|---------|
| `profile/` | Nix flake (not stowed): `global`, the one set of command-line tools every machine adds to its nix profile |

## Adding Configuration

1. Put the file at its `$HOME` path under `home/` (e.g. `home/.config/app/config`)
2. Run `./install`, unless it lands inside an already-linked directory (then it's live)
3. If something besides the repo also writes into that directory (state, other
   tools' drop-ins), add it to `./install`'s `mkdir -p` list so it stays real
