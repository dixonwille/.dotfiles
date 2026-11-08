---
name: stow-management
description: GNU Stow operations for this dotfiles repo. Use when installing packages, creating symlinks, or troubleshooting stow issues.
---

# Stow Management

GNU Stow creates symlinks from package directories to target locations (default: `$HOME`).

## Quick Reference

```bash
# Everything: home/, personal/base, and personal/work on the work machine
./install

# Manual (from repo root): what ./install runs
stow -d . -t "$HOME" home   # not -R: see ./install
stow -R -d personal -t "$HOME" --no-folding base work
```

## Install Script

`./install` (repo root; one script for every machine). A fresh machine needs only
`git clone https://github.com/dixonwille/.dotfiles.git ~/.dotfiles` (HTTPS: the
repo is public, and no credentials are set up yet); `./install` then:
1. Removes dangling links into this repo (files moved or deleted since the last
   run), which stow neither cleans up nor stows over: only links whose target is
   in the repo, in `~`, `~/.config` (3 levels), `~/.local/{bin,share}`, `~/.ssh`
   and `~/Projects`. So renaming files in `home/` needs no manual cleanup
2. Checks out the public submodules (zsh plugins, HTTPS); only ones not checked
   out yet, since `git submodule update` would move one back to the recorded commit
3. Creates the directories something besides the repo writes into (`~/.ssh`,
   `~/.local/bin`, `~/.config/{git,jj,zsh,environment.d,direnv,nix}`), so they
   stay real directories, and stows `home/` (one package mirroring `$HOME`).
   That gives ssh its config, which points it at 1Password's agent
4. Checks out `personal/` (private, SSH, through that agent); if it can't, says
   so and skips the private layer (re-run later). Then stows `personal/base`
5. Sets `origin`'s push URL to SSH when the clone used HTTPS
6. Adds the nix profile's `global` set (`profile/`)
7. Links `op-ssh-sign` from whichever 1Password app is installed; on WSL, also
   `git.exe` and the Windows-side WezTerm config
8. Runs `personal/install`, the private submodule's own layer, if it has one

The private packages are a separate stow directory: `stow -d personal -t "$HOME" --no-folding base`.

## Folding

By default stow links the highest directory it can: where `~/.config/nvim`
doesn't exist, it becomes one link to `home/.config/nvim`, so files added to the
repo appear without a restow. Where the target directory already exists, stow
links file by file inside it. So the folding choice is per target directory, and
lives in `./install`'s `mkdir -p` list: a directory that other programs also
write into (ssh's `known_hosts`, other tools' env files, `personal/`'s
files) must exist before stowing, or their files land in the repo.

`personal/` is always stowed `--no-folding`: it only adds files.

## Common Operations

See `examples.md` for detailed examples of:
- Adding new packages
- Unstowing packages
- Handling conflicts
- Restowing after changes
