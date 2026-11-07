# Dotfiles

Personal dotfiles repository using GNU Stow for symlink management, following XDG Base Directory specifications.

## Repository Structure

`home/` mirrors `$HOME`: a file at `home/<path>` is linked at `~/<path>`, the same on every machine. What differs by machine is decided at runtime by the configs themselves (ssh's 1Password agent, git's and jj's work identity), or by `./install`.

```
.dotfiles/
├── home/                      # Stowed into $HOME on every machine
│   ├── .config/               # git, jj, mise, nix, direnv, nvim, oh-my-posh,
│   │                          # tmux, zsh, ghostty, wezterm (Windows, for WSL)
│   ├── .local/bin/            # Custom scripts (e.g., project-list, tmux-sessionizer)
│   ├── .local/share/zsh/plugins/  # Git submodules for Zsh plugins
│   ├── .ssh/                  # SSH configuration
│   └── .zshenv
├── personal/                  # Private git submodule: base (every machine), work
├── profile/                   # Nix flake: the command-line tools for the nix profile
└── install                    # Sets up any machine (stow, nix profile, glue)
```

**Key Features:**
- **XDG Compliance**: All configurations respect XDG Base Directory specification
- **One environment**: variables in systemd's `environment.d`, read by systemd and zsh alike
- **Private Submodule**: Sensitive work configurations isolated in `personal/` submodule
- **Custom Scripts**: Utilities like `tmux-sessionizer` for workflow automation

## Quick Start

### Minimal Required Tools

Before installation, ensure these tools are available:

```bash
# Essential tools
sudo apt install git stow curl wget tar gcc make unzip
```

Plus [Nix](https://nixos.org/download/) (multi-user). `./install` adds the
everyday command-line tools to your nix profile (see
[Command-Line Tools](#command-line-tools-nix-profile)). On the work WSL, run the
work machine's own setup's bootstrap
first: it provides Nix, and `./install` then adds `personal/work`.

### Installation

#### Option 1: Using Install Script (Recommended)

```bash
git clone --recurse-submodules git@github.com:dixonwille/.dotfiles.git ~/.dotfiles
~/.dotfiles/install
```

The same on every machine, and safe to re-run.

#### Option 2: Manual Stow Installation

```bash
cd ~/.dotfiles
# Directories other programs also write into must exist first (see ./install)
mkdir -p ~/.config/{git,jj,zsh,environment.d,direnv,nix} ~/.local/{bin,share} ~/.ssh
stow -R -d . -t "$HOME" home
stow -R -d personal -t "$HOME" --no-folding base   # and work, on the work machine
```

**Note**: stow folds a directory that doesn't exist yet into one link, so new
files in the repo show up without a restow; the ones `./install` creates first
stay real and get file-by-file links.

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
  sqlite, codecrafters, cloudflared, htop, claude, and on Linux inotify-tools
  (Neovim's file watching for language servers) and wl-clipboard (Neovim's and
  gh's clipboard)

```bash
nix profile add "path:$HOME/.dotfiles/profile#global"
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
  team CLIs. `~/Projects/mise.toml` (`personal/work`) adds the editor tools
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
- **Project tools**: `mise activate` puts each project's `mise.toml` tools on PATH while in it
- **Work integration**: Loads `~/.config/zsh/.zshrc_work` (from `personal/work`: the workstation's its init) if present

## Environment Configuration

### environment.d

Every environment variable is in `~/.config/environment.d/*.conf`, systemd's
format (`KEY=VALUE`, `$VAR` expansion only; no spaces or quotes, lists use `:`),
as the work workstation's `env file`. The systemd user manager reads them;
`.zshenv` sources them for shells it didn't start, and keeps each PATH entry once.

- `home/.config/environment.d/999-path.conf` - `~/.local/bin`, `~/.cargo/bin`
  (`999-`: after Ubuntu's `99-environment.conf`, which sets PATH outright)
- `personal/work/.config/environment.d/` - work's values

## Development Workflow

Since this is a dotfiles repository, typical operations include:

### Adding New Configurations
1. Put the file at its `$HOME` path under `home/` (e.g. `home/.config/app/config`)
2. Run `./install` (not needed when it lands in an already-linked directory)
3. If the app also writes its own files into that directory, add it to
   `./install`'s `mkdir -p` list, so it stays a real directory

### Updating Existing Configurations
- Edit files directly - changes reflect immediately via symlinks
- For shell configs, source updated files or restart terminal

### Privacy Notes
- The `personal/` directory is a private git submodule containing sensitive information
- Main repository is public; sensitive configurations are isolated in the private submodule
- Be aware that some settings may reference private data from this submodule
