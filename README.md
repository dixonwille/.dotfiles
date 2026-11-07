# Dotfiles

Personal dotfiles repository using GNU Stow for symlink management, following XDG Base Directory specifications.

## Repository Structure

This dotfiles setup organizes configurations by application, with each directory containing `.config/` subdirectories that get stowed to `~/.config/`:

```
.dotfiles/
├── bin/.local/bin/            # Custom scripts (e.g., project-list, tmux-sessionizer)
├── git/.config/git/           # Git configuration
├── hyprland/.config/hyprland/ # Hyprland window manager config
├── nvim/.config/nvim/         # Neovim configuration
├── tmux/.config/tmux/         # Tmux configuration  
├── mise/.config/mise/         # mise settings (no tools: those are per project)
├── zsh/.config/zsh/           # Zsh shell configuration
├── zsh-plugins/               # Git submodules for Zsh plugins
├── personal/                  # Private git submodule (work configs, secrets)
├── profile/                   # Nix flake: command-line tool sets for the nix profile
├── install/                   # Installation scripts
└── CLAUDE.md                  # Instructions for Claude Code
```

**Key Features:**
- **XDG Compliance**: All configurations respect XDG Base Directory specification
- **Modular Environment**: `env.d` system for environment variables with load-order control
- **Private Submodule**: Sensitive work configurations isolated in `personal/` submodule
- **Custom Scripts**: Utilities like `tmux-sessionizer` for workflow automation

## Quick Start

### Minimal Required Tools

Before installation, ensure these tools are available:

```bash
# Essential tools
sudo apt install git stow curl wget tar gcc make unzip
```

Plus [Nix](https://nixos.org/download/) (multi-user). The install scripts add
the everyday command-line tools to your nix profile (see
[Command-Line Tools](#command-line-tools-nix-profile)).

### Installation

#### Option 1: Using Install Script (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Set packages to install and run installer
PKGS="zsh tmux nvim git bin" ./install/install
```

#### Option 2: Manual Stow Installation

```bash
# Clone and navigate to repository
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Stow individual packages
stow -Rt "$HOME" zsh
stow -Rt "$HOME" tmux
stow -Rt "$HOME" nvim
stow -Rt "$HOME" git

# For packages that need no-folding (like bin/)
stow -Rt "$HOME" --no-folding bin
```

**Note**: Some packages use the `--no-folding` flag, controlled by `.no-fold` files in their directories.

## Complete Tool List

### Essential Tools
- **git** - Version control
- **stow** - Symlink management
- **curl/wget** - Download utilities
- **tar/unzip** - Archive tools
- **gcc/make** - C toolchain for building tools

### Command-Line Tools (nix profile)
`profile/` holds sets of command-line tools I need whatever the project,
newer than a distribution's packages, that each machine's install script adds
to its nix profile:

- **global** (every machine) - mise, oh-my-posh, tmux, fzf, eza, bat, tealdeer,
  taskwarrior, neovim, tree-sitter, ripgrep, fd, gh, delta, jujutsu, jq, yq,
  sqlite, cloudflared, htop, claude, and on Linux inotify-tools (Neovim's
  file watching for language servers) and wl-clipboard (Neovim's and gh's
  clipboard)
- **personal** - typst, codecrafters

```bash
nix profile add "path:$HOME/.dotfiles/profile#global" "path:$HOME/.dotfiles/profile#personal"
```

After editing a set, or `nix flake update` in `profile/`, run
`nix profile upgrade --all`.

### Project Tools (mise)
A project's tools aren't global: runtimes, language servers, formatters and
linters come from the project's `mise.toml` (and `mise.lock`), at the versions
its CI uses, and are on PATH only inside it (`mise activate` in `.zshrc`).
`~/.config/mise/config.toml` holds settings only, never `[tools]`.

- **My projects** - commit `mise.toml`; CI reads the same file
  (`jdx/mise-action`).
- **Someone else's repo** - `mise.local.toml`, ignored by the global git
  ignore.
- **Work** (WSL, on the work machine's own setup) -
  the workstation provides the runtimes (dotnet, go, node, pwsh, bicep, uv) and
  team CLIs. `~/Projects/mise.toml` (`personal/mise-work`) adds the editor tools
  for every clone under it, and never a runtime. A repo whose CI pins something
  else gets its own `mise.local.toml`.
- **This repo** - its `mise.toml` has the Lua and shell tools. Nix tooling
  (nixd, nixfmt) has no release binaries for mise: for `profile/`, run nvim
  under `nix shell nixpkgs#nixd nixpkgs#nixfmt`.

### Other Tools
- **JetBrainsMono Nerd Font Mono** - Font with programming ligatures
- **1Password** - Desktop app (its CLI integration needs the system's `op`)

## Key Features

### Project jumping
- **`Ctrl+f` in zsh**: fzf over `project-list` (`~/Projects`, `~/projects`, `~/.dotfiles`), then `cd` there
- **`tmux-sessionizer`**: run by name when something must outlive the terminal; creates or switches to a tmux session for the project

### Shell Configuration (Zsh)
- **Vi mode**: Enabled by default
- **History**: 10k entries in XDG-compliant location
- **Plugins**: zsh-autosuggestions, zsh-syntax-highlighting (via git submodules)
- **Work integration**: Loads `~/.config/zsh/.zshrc_work` if present

## Environment Configuration

### environment.d and env.d

- **Plain values** - `~/.config/environment.d/*.conf`, systemd's format
  (`KEY=VALUE`, `$VAR` expansion only; no spaces or quotes, lists use `:`), as
  the work workstation's `env file`. The systemd user manager reads them;
  `.zshenv` sources them for shells it didn't start. Work's are in
  `personal/environment-work/`.
- **Shell code** (PATH, functions, secrets) - zsh's `env.d`:
  `zsh/.config/zsh/env.d/` (all machines)

### 1Password Secret Management

The `_cache_op_secret()` function provides secure caching of 1Password secrets with a 30-day TTL.

**Usage in env.d files:**
```bash
# Basic usage (uses my.1password.com by default)
export MY_SECRET="$(_cache_op_secret "op://vault/item/field" "MY_SECRET")"

# Specify a different 1Password account
export WORK_SECRET="$(_cache_op_secret "op://vault/item/field" "WORK_SECRET" "company.1password.com")"

# Examples
export GITHUB_TOKEN="$(_cache_op_secret "op://Private/GitHub Token/credential" "GITHUB_TOKEN")"
export API_KEY="$(_cache_op_secret "op://Work/API Keys/production" "API_KEY")"
export WORK_TOKEN="$(_cache_op_secret "op://Work/Token/credential" "WORK_TOKEN" "company.1password.com")"
```

**Features:**
- Automatic 1Password CLI authentication when needed
- Secure cache with 600 permissions (user read/write only)
- 30-day cache TTL to minimize CLI calls
- Graceful fallback to cached values if authentication fails
- Cache location: `~/.cache/zsh/op-secrets/`

## Development Workflow

Since this is a dotfiles repository, typical operations include:

### Adding New Configurations
1. Create new package directory following `app/.config/app/` pattern
2. Add configuration files in appropriate subdirectories
3. Create `.no-fold` file if needed for the package
4. Test with `stow -Rt "$HOME" app`

### Updating Existing Configurations
- Edit files directly - changes reflect immediately via symlinks
- For shell configs, source updated files or restart terminal

### Managing Secrets
- Add new secrets to appropriate `env.d/` files using `_cache_op_secret()`
- Environment files are numbered (e.g., `10-paths.zsh`, `20-tmpdir.zsh`) to control load order

### Privacy Notes
- The `personal/` directory is a private git submodule containing sensitive information
- Main repository is public; sensitive configurations are isolated in the private submodule
- Be aware that some settings may reference private data from this submodule
