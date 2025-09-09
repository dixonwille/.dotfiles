# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Structure

This is a personal dotfiles repository using GNU Stow for symlink management. The structure follows XDG Base Directory specifications:

- **Application configs**: Each directory contains `.config/` subdirectories that get stowed to `~/.config/`
- **Binaries**: `bin/.local/bin/` contains custom scripts
- **Git submodules**: `zsh-plugins/` contains Zsh plugin submodules
- **Private submodule**: `personal/` is a private git submodule containing sensitive personal information (work configs, private settings, etc.)
- **Specialized configs**: `hyprland/`, `wsl/`, etc. for environment-specific settings

## Installation and Management

### Stowing Packages
```bash
# Install all packages (set PKGS environment variable first)
PKGS="zsh tmux nvim git" ./install/install

# Manual stow (from repo root)
stow -Rt "$HOME" zsh
stow -Rt "$HOME" --no-folding bin  # Uses .no-fold file
```

The install script (`install/install`) uses GNU Stow to create symlinks. Some packages use `--no-folding` flag controlled by `.no-fold` files.

### Environment Configuration System

The repository uses a modular `env.d` system for environment variables:

- **Main**: `zsh/.config/zsh/env.d/` - Environment files loaded for all machines
- **Work-specific**: `personal/zsh-work/.config/zsh/env.d/` - Additional work environment files (private submodule)

Environment files are numbered (e.g., `10-paths.zsh`, `20-tmpdir.zsh`) to control load order.

## Key Tools and Dependencies

Required tools (see README.md for complete list):
- **GNU Stow**: For symlink management
- **Neovim**: Editor (nightly v0.12+)
- **tmux**: Terminal multiplexer
- **fzf**: Fuzzy finder (used by tmux-sessionizer)
- **ripgrep, fd-find**: Search tools
- **1Password CLI**: For secret management (optional)
- **uv/uvx**: For MCP servers

## Custom Scripts

### tmux-sessionizer (`bin/.local/bin/tmux-sessionizer`)
- **Purpose**: Quick tmux session switching using fzf
- **Keybind**: `Ctrl+f` in zsh
- **Usage**: Searches `~/projects` and `~/.config` for directories and creates/switches tmux sessions
- **Behavior**: Creates new sessions if they don't exist, switches to existing ones

## Secret Management

Uses 1Password CLI with caching system via `_cache_op_secret()` function:
- **Location**: Environment files in `env.d/` directories  
- **Cache TTL**: 30 days
- **Cache location**: `~/.cache/zsh/op-secrets/`
- **Usage pattern**: `export TOKEN="$(_cache_op_secret "op://vault/item/field" "TOKEN_NAME" ["account"])"`
- **Account**: Optional 3rd parameter to specify 1Password account (defaults to `my.1password.com`)

## Shell Configuration

### Zsh Setup
- **Main config**: `zsh/.config/zsh/.zshrc`
- **History**: Stored in XDG-compliant location with 10k entries
- **Vi mode**: Enabled by default
- **Plugins**: zsh-autosuggestions, zsh-syntax-highlighting (via git submodules)
- **Prompt**: oh-my-posh (optional)

### Key Features
- **XDG compliance**: All configs respect XDG Base Directory specification
- **Conditional loading**: Tools and plugins load only if available
- **Work integration**: Separate work config loaded if present (`~/.config/zsh/.zshrc_work`)

## Development Workflow

Since this is a dotfiles repo, the primary operations are:
1. **Adding new configs**: Create new package directories following the `app/.config/app/` pattern
2. **Updating configs**: Edit files directly, changes reflect immediately via symlinks  
3. **Managing secrets**: Add new secrets to appropriate `env.d/` files using `_cache_op_secret()`
4. **Testing changes**: Source updated shell configs or restart terminals

## Privacy Notes

- The `personal/` directory is a private git submodule containing sensitive information
- When working with configs, be aware that some settings may reference private data from this submodule
- The main repository is public; sensitive configurations are isolated in the private submodule