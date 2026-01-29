# Packages Reference

Complete list of stow packages in this repository.

## Core Packages

| Package | Purpose | Target |
|---------|---------|--------|
| `bin` | Custom scripts | `~/.local/bin/` |
| `git` | Git configuration | `~/.config/git/` |
| `git-wsl` | WSL-specific git config | `~/.config/git/` |
| `nvim` | Neovim configuration | `~/.config/nvim/` |
| `tmux` | tmux configuration | `~/.config/tmux/` |
| `zsh` | Zsh shell configuration | `~/.config/zsh/` |

## Environment-Specific

| Package | Purpose | When to use |
|---------|---------|-------------|
| `hyprland` | Hyprland WM config | Linux with Hyprland |
| `wsl` | WSL-specific settings | Windows Subsystem for Linux |
| `ssh-linux` | SSH config for Linux | Linux systems |
| `ssh-macos` | SSH config for macOS | macOS systems |

## Applications

| Package | Purpose |
|---------|---------|
| `ghostty` | Ghostty terminal config |
| `jj` | Jujutsu VCS config |
| `nix` | Nix package manager config |
| `oh-my-posh` | Shell prompt theme |
| `claude` | Global Claude SubAgents and Skills |

## Support Directories

| Directory | Purpose |
|-----------|---------|
| `install/` | Installation scripts |
| `personal/` | Private submodule (work configs) |
| `zsh-plugins/` | Zsh plugin submodules |

## Adding New Packages

1. Create directory: `new-package/.config/new-package/`
2. Add config files inside
3. Stow: `stow -Rt "$HOME" new-package`
4. If symlink folding causes issues, create `.no-fold` file in package root
