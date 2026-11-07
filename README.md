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

### Before you start

- **1Password**, the desktop app, signed in, with Settings → Developer → **Use the
  SSH agent** on: git reaches the private submodule and signs commits through it.
  On WSL that's 1Password for Windows, which the work machine's own setup covers.
- **git, stow, curl, tar and a C compiler.** stow links the files; Neovim's
  treesitter downloads parsers with curl and tar and compiles them (tree-sitter
  calls `cc`):
  - Ubuntu: `sudo apt install zsh git stow curl build-essential`
  - CachyOS / Arch: `sudo pacman -S --needed zsh git stow curl base-devel`
  - macOS: `xcode-select --install` (git and the compiler; curl and tar ship
    with macOS), then `brew install stow`
- **zsh** as the login shell, once installed: `chsh -s "$(command -v zsh)"`,
  then a new terminal (already the default on macOS).
- **[Nix](https://nixos.org/download/)**, multi-user. On a machine with its own
  setup (work), run that first: it installs Nix.
- For the terminal: Ghostty (Linux, macOS) or WezTerm (Windows, for WSL), and
  the fonts both configs use: **Maple Mono NF CN** (text, CJK and Nerd Font
  icons; from [its releases](https://github.com/subframe7536/maple-font/releases))
  and **DejaVu Sans Mono** (the symbols Maple lacks). For WezTerm, install them
  on Windows, not in WSL.

### Install

```bash
git clone https://github.com/dixonwille/.dotfiles.git ~/.dotfiles
~/.dotfiles/install
```

Then open a new terminal. Clone over HTTPS: the repo is public, so the clone
needs no credentials, which a new machine doesn't have set up yet. `./install`
does the rest, in this order:

1. Checks out the zsh plugins (public submodules, over HTTPS).
2. Links `home/` into `$HOME`, after creating the directories other tools also
   write into, so those stay real. That includes `~/.ssh/config`, which points
   ssh at 1Password's agent.
3. Checks out `personal/` (private, over SSH, through that agent). The first
   connection asks you to confirm GitHub's host key, and 1Password to approve.
   If it can't (1Password not running yet), it says so and skips the private
   layer.
4. Links `personal/base`, and sets `origin`'s push URL to SSH (fetching stays
   anonymous, over HTTPS).
5. Adds the `global` set to the nix profile.
6. Links `op-ssh-sign` from the installed 1Password app; on WSL also `git.exe`
   and WezTerm's Windows-side config.
7. Runs `personal/install`, the private layer's own step.

It's safe to re-run, and that's how to finish anything it skipped (e.g. after
starting 1Password) or to pick up changes after a pull. To do it by hand, read
`install`: it's short, and commented.

## Tools

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
its CI uses, and are on PATH only inside it (`mise activate` in `.zshrc`). No
direnv: mise doesn't support running beside it.
`~/.config/mise/config.toml` holds settings only, never `[tools]`.

- **My projects** - commit `mise.toml`; CI reads the same file
  (`jdx/mise-action`).
- **Someone else's repo** - `mise.local.toml`, ignored by the global git
  ignore.
- **A machine with its own setup** (work) - that setup provides the runtimes;
  the private layer can add editor tools for its repos through a parent
  directory's `mise.toml` (mise merges parent configs), never a runtime.
- **This repo** - its `mise.toml` has the Lua and shell tools. Nix tooling
  (nixd, nixfmt) has no release binaries for mise: for `profile/`, run nvim
  under `nix shell nixpkgs#nixd nixpkgs#nixfmt`.

## Key Features

### Project jumping
- **`Ctrl+f` in zsh**: fzf over `project-list` (`~/Projects`, `~/projects`, `~/.dotfiles`), then `cd` there
- **`tmux-sessionizer`**: run by name when something must outlive the terminal; creates or switches to a tmux session for the project

### Shell Configuration (Zsh)
- **Vi mode**: Enabled by default
- **History**: 10k entries in XDG-compliant location
- **Plugins**: zsh-autosuggestions, zsh-syntax-highlighting (via git submodules)
- **Project tools**: `mise activate` puts each project's `mise.toml` tools on PATH while in it;
  where something already hooked direnv, mise's shims go last on PATH instead
- **Work integration**: Loads `~/.config/zsh/.zshrc_work` (from the private submodule) if present

## Environment Configuration

### environment.d

Every environment variable is in `~/.config/environment.d/*.conf`, systemd's
format (`KEY=VALUE`, `$VAR` expansion only; no spaces or quotes, lists use `:`),
beside any other tools' files there. The systemd user manager reads them;
`.zshenv` sources them for shells it didn't start, and keeps each PATH entry once.

- `home/.config/environment.d/20-editor.conf` - `EDITOR`
- `home/.config/environment.d/999-path.conf` - `~/.local/bin`
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
- After a pull, run `./install` (new files, moved files, the nix set)

### Privacy Notes
- The `personal/` directory is a private git submodule containing sensitive information
- Main repository is public; sensitive configurations are isolated in the private submodule
- Be aware that some settings may reference private data from this submodule
