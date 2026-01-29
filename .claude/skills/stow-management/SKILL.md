---
name: stow-management
description: GNU Stow operations for this dotfiles repo. Use when installing packages, creating symlinks, or troubleshooting stow issues.
---

# Stow Management

GNU Stow creates symlinks from package directories to target locations (default: `$HOME`).

## Quick Reference

```bash
# Install multiple packages via install script
PKGS="zsh tmux nvim git" ./install/install

# Manual stow (from repo root)
stow -Rt "$HOME" package-name

# With --no-folding (when .no-fold file exists)
stow -Rt "$HOME" --no-folding bin
```

## Install Script

The `install/install` script:
1. Reads `PKGS` environment variable (space-separated package names)
2. Checks for `.no-fold` file in each package
3. Runs stow with appropriate flags

## The --no-folding Flag

By default, stow creates symlinks at the highest possible directory level. The `--no-folding` flag creates symlinks for individual files instead.

**Use --no-folding when:**
- Package directory might receive additional files not from this repo
- Want to mix stowed and non-stowed files in same directory

**Controlled by:** `.no-fold` file in package root (presence triggers flag)

## Common Operations

See `examples.md` for detailed examples of:
- Adding new packages
- Unstowing packages
- Handling conflicts
- Restowing after changes
