---
name: dotfiles-overview
description: Structure and organization of this dotfiles repository. Use when working with configs, understanding where files belong, or navigating the repository.
user-invocable: false
---

# Dotfiles Repository Overview

Personal dotfiles repository using GNU Stow for symlink management, following XDG Base Directory specifications.

## Directory Pattern

All application configs follow: `app/.config/app/` → symlinked to `~/.config/app/`

```
package-name/
└── .config/
    └── package-name/
        └── config files...
```

## Core Structure

- **Application configs**: Directories with `.config/` subdirectories stowed to `~/.config/`
- **Binaries**: `bin/.local/bin/` contains custom scripts → `~/.local/bin/`
- **Git submodules**: `zsh-plugins/` contains Zsh plugin submodules
- **Private submodule**: `personal/` is a private git submodule (work configs, secrets)
- **Environment-specific**: `hyprland/`, `wsl/` for specialized setups

## Key Tools

- **GNU Stow**: Symlink management
- **Neovim**: Editor (nightly v0.12+)
- **tmux**: Terminal multiplexer
- **fzf**: Fuzzy finder
- **1Password CLI**: Secret management

## Privacy Notes

- `personal/` is a private submodule containing sensitive information
- Main repository is public; sensitive configs isolated in private submodule
- Some settings may reference private data from `personal/`

## Reference

See `packages.md` for complete list of all packages and their purposes.
