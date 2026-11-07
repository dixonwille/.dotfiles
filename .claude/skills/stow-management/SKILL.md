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
stow -R -d . -t "$HOME" home
stow -R -d personal -t "$HOME" --no-folding base work
```

## Install Script

`./install` (repo root; one script for every machine):
1. Creates the directories something besides the repo writes into (`~/.ssh`,
   `~/.local/bin`, `~/.config/{git,jj,zsh,environment.d,direnv,nix}`), so they
   stay real directories
2. Stows `home/` (one package mirroring `$HOME`), then `personal/base`, and
   `personal/work` where the work machine's own setup is installed (`work` on PATH)
3. Adds the nix profile's `global` set (`profile/`)
4. Links `op-ssh-sign` from whichever 1Password app is installed; on WSL, also
   `git.exe` and the Windows-side WezTerm config

## Folding

By default stow links the highest directory it can: where `~/.config/nvim`
doesn't exist, it becomes one link to `home/.config/nvim`, so files added to the
repo appear without a restow. Where the target directory already exists, stow
links file by file inside it. So the folding choice is per target directory, and
lives in `./install`'s `mkdir -p` list: a directory that other programs also
write into (ssh's `known_hosts`, the workstation's env file, `personal/`'s
files) must exist before stowing, or their files land in the repo.

`personal/` is always stowed `--no-folding`: it only adds files.

## Common Operations

See `examples.md` for detailed examples of:
- Adding new packages
- Unstowing packages
- Handling conflicts
- Restowing after changes
