---
name: shell-config
description: Zsh shell configuration. Use when modifying shell settings, plugins, or work integration.
user-invocable: false
---

# Shell Configuration

Zsh configuration following XDG Base Directory specification.

## File Locations

| File | Purpose |
|------|---------|
| `zsh/.config/zsh/.zshrc` | Main configuration |
| `zsh/.config/zsh/env.d/` | Environment variables |
| `~/.config/zsh/.zshrc_work` | Work-specific (if exists) |

## Key Features

- **XDG compliance**: All configs in `~/.config/zsh/`
- **Vi mode**: Enabled by default
- **History**: 10k entries, XDG-compliant location
- **Conditional loading**: Tools/plugins load only if available

## Plugins

Managed via git submodules in `zsh-plugins/`:

| Plugin | Purpose |
|--------|---------|
| zsh-autosuggestions | Fish-like autosuggestions |
| zsh-syntax-highlighting | Command syntax highlighting |

## Prompt

Uses oh-my-posh (optional). Config in `oh-my-posh/.config/oh-my-posh/`.

## Work Integration

If `~/.config/zsh/.zshrc_work` exists, it's sourced automatically. This allows machine-specific settings without modifying the main config.

## Testing Changes

```bash
# Source updated config
source ~/.config/zsh/.zshrc

# Or start new shell
zsh
```

## Adding Aliases/Functions

Add to `.zshrc` or create new file in `env.d/` if environment-related.
