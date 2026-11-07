---
name: dotfiles-overview
description: Structure and organization of this dotfiles repository. Use when working with configs, understanding where files belong, or navigating the repository.
user-invocable: false
---

# Dotfiles Repository Overview

Personal dotfiles repository using GNU Stow for symlink management, following XDG Base Directory specifications.

## Directory Pattern

`home/` mirrors `$HOME` and is the one public stow package, the same on every
machine: a file at `home/<path>` is linked at `~/<path>`.

```
home/
├── .config/<app>/...   → ~/.config/<app>/
├── .local/bin/...      → ~/.local/bin/ (custom scripts)
├── .local/share/zsh/plugins/  (zsh plugin submodules)
├── .ssh/...
└── .zshenv
```

## Core Structure

- **Folding**: stow links a whole directory where the target doesn't exist yet,
  so new files appear without a restow. `./install` first creates the
  directories something else also writes into (`~/.ssh`, `~/.local/bin`,
  `~/.config/{git,jj,zsh,environment.d,direnv,nix}`), which stow then fills file
  by file. A new such directory goes in that `mkdir` list.
- **Git submodules**: `home/.local/share/zsh/plugins/` holds the Zsh plugin submodules
- **Private submodule**: `personal/` is a private git submodule (personal identity, work configs)
- **Same everywhere**: every machine stows all of `home/`; differences are decided at runtime or by `./install`. A machine with its own setup (work) owns its system side; the private submodule's `personal/install` adds its layer (documented in the submodule's own skill)

## Key Tools

- **GNU Stow**: Symlink management
- **Neovim**: Editor (nightly v0.12+)
- **tmux**: Terminal multiplexer
- **fzf**: Fuzzy finder
- **1Password**: SSH agent and commit signing (`op-ssh-sign`)

## Privacy Notes

- `personal/` is a private submodule containing sensitive information
- Main repository is public; sensitive configs isolated in private submodule
- Some settings may reference private data from `personal/`

## Reference

See `packages.md` for complete list of all packages and their purposes.
