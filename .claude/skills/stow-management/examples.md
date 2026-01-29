# Stow Examples

## Installing Packages

```bash
# Single package
stow -Rt "$HOME" nvim

# Multiple packages
PKGS="zsh tmux nvim git" ./install/install

# With verbose output
stow -Rvt "$HOME" nvim
```

## Removing Symlinks

```bash
# Unstow (remove symlinks)
stow -Dt "$HOME" nvim

# Restow (unstow then stow - useful after changes)
stow -Rt "$HOME" nvim
```

## Handling --no-folding

```bash
# Check if package uses no-folding
ls bin/.no-fold

# Manual stow with no-folding
stow -Rt "$HOME" --no-folding bin
```

## Creating New Package

```bash
# 1. Create package structure
mkdir -p new-app/.config/new-app

# 2. Add config files
cp /path/to/config new-app/.config/new-app/

# 3. Stow it
stow -Rt "$HOME" new-app

# 4. (Optional) Add .no-fold if needed
touch new-app/.no-fold
```

## Troubleshooting

### Conflict with existing file
```bash
# Backup existing file first
mv ~/.config/app/config ~/.config/app/config.bak

# Then stow
stow -Rt "$HOME" app
```

### Preview without making changes
```bash
# Simulate (dry-run)
stow -nRvt "$HOME" nvim
```

### Check what would be created
```bash
stow -nvt "$HOME" package-name 2>&1 | grep -E "^(LINK|UNLINK)"
```
