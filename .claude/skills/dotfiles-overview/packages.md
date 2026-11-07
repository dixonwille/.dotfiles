# Packages Reference

Complete list of stow packages in this repository.

## Core Packages

| Package | Purpose | Target |
|---------|---------|--------|
| `bin` | Custom scripts | `~/.local/bin/` |
| `git` | Git configuration | `~/.config/git/` |
| `nvim` | Neovim configuration | `~/.config/nvim/` |
| `tmux` | tmux configuration | `~/.config/tmux/` |
| `zsh` | Zsh shell configuration | `~/.config/zsh/` |

## Environment-Specific

| Package | Purpose | When to use |
|---------|---------|-------------|
| `hyprland` | Hyprland WM config | Linux with Hyprland |
| `ssh-linux` | SSH config for Linux | Linux systems |
| `ssh-macos` | SSH config for macOS | macOS systems |

## Applications

| Package | Purpose |
|---------|---------|
| `ghostty` | Ghostty terminal config |
| `jj` | Jujutsu VCS config |
| `nix` | Nix config (`nix.conf`) and direnv's settings (`direnv.toml`; direnv itself is the work workstation's, for repos with their own flake) |
| `mise` | mise's global settings only (`~/.config/mise/config.toml`); tools are per project |
| `oh-my-posh` | Shell prompt theme |
| `claude` | Global Claude SubAgents and Skills |

## Support Directories

| Directory | Purpose |
|-----------|---------|
| `install/` | Installation scripts |
| `profile/` | Nix flake (not stowed) of the command-line tool sets each machine adds to its nix profile: `global`, `personal` |
| `personal/` | Private submodule (work configs; `mise-work` stows `~/Projects/mise.toml`) |
| `zsh-plugins/` | Zsh plugin submodules |

## Adding New Packages

1. Create directory: `new-package/.config/new-package/`
2. Add config files inside
3. Stow: `stow -Rt "$HOME" new-package`
4. If symlink folding causes issues, create `.no-fold` file in package root
